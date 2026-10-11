# Collection & barcode scanner

Answer the store question — *"do I already own this?"* — by scanning a barcode
and checking it against your Jellyfin library and your physical collection.

Everything is **client-side**: the app holds no server and no database. Your
Jellyfin library is imported as a **snapshot**, and your physical list lives in
this browser / your Google Drive.

## 1. Build the Jellyfin snapshot

The app can't reach Jellyfin from a phone in a store (the LAN URL doesn't
resolve off-LAN, and the Access-gated hostname breaks cross-origin `fetch`), so
you generate a snapshot once and import it.

Create an API key in Jellyfin (**Dashboard → API Keys → +**), then run the
generator on the homelab (or anywhere that can reach Jellyfin):

```sh
JELLYFIN_URL=http://127.0.0.1:8096 JELLYFIN_API_KEY=xxxx \
  node scripts/jellyfin-inventory.mjs library.json
```

Output shape (what the app imports):

```json
{ "generatedAt": "…", "server": "http://…", "count": 1234,
  "items": [ { "name": "The Matrix", "type": "Movie", "year": 1999,
               "tmdbId": "603", "imdbId": "tt0133093", "path": "…" } ] }
```

Re-run it whenever your library changes, then re-import.

## 2. Import it

Admin → **collection & scanner** → **import library.json**. The snapshot is
stored in `localStorage` and, if auto-backup is on, in your Google Drive.

## 3. Scan

The **Scan** tab:

1. **Scan barcode** (camera, `BarcodeDetector`) or type a UPC/EAN.
2. The UPC is resolved through the **proxy** to **UPCitemdb** → a title.
3. **TMDB** (if a key is set) adds the poster/year/synopsis.
4. The title is matched against the snapshot and your physical list.

Verdicts:

| Verdict | Meaning |
|---|---|
| `OWNED · server` | title is in your Jellyfin snapshot |
| `OWNED · server (check edition)` | close match, year/edition differs |
| `OWNED · physical` | title is in your physical list |
| `NOT OWNED` | neither |

Matching normalizes titles (lowercase, drops punctuation, articles, and format
words like *blu-ray/dvd/4k/steelbook*) and uses token-set overlap.

## 4. Physical collection & export

- **＋ add to physical** records a scan into your physical list (title + UPC).
- Admin → **export json / export csv** dumps the server snapshot.

## Configuration

| Setting | Where | Notes |
|---|---|---|
| `collection.proxy` | Admin | wraps UPCitemdb, which blocks browser origins. Default `https://api.allorigins.win/raw?url={url}` |
| `collection.tmdbKey` | Admin | optional; posters/metadata. Free at themoviedb.org |

## Limitations

- **UPCitemdb blocks CORS**, so it goes through the proxy. The proxy sees the
  UPCs you look up; point it at your own proxy for privacy. It can be slow.
- **`BarcodeDetector`** is Chrome/Edge (Android). iOS Safari lacks it — type the
  UPC instead. (A JS decoder fallback is a possible follow-up.)
- **UPC coverage**: recent releases are often missing from UPCitemdb. A second
  provider (UPCMDB) is a possible follow-up.
- **Snapshot, not live** — re-run the generator after adding media.
- Titles with heavy editions/extras can over- or under-match; the verdict is a
  hint, not gospel.

## Privacy

UPCs you scan go to UPCitemdb (via the proxy); TMDB lookups go to TMDB. Nothing
is sent to any server of ours — there isn't one. The snapshot and physical list
stay in your browser and (optionally) your own Drive.

## Patterns studied

The "thrifting mode" / barcode-waterfall / ownership model is inspired by two
MIT projects: [BOCollections](https://github.com/N0t4R0b0t/BOCollections) and
[Armarium](https://github.com/craig530/Armarium).
