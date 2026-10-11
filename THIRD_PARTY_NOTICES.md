# Third-Party Notices

Crypt Dashboard is licensed under **AGPL-3.0-or-later** (see [LICENSE](LICENSE)).
This file records the third-party projects whose code or patterns were adapted,
and their licenses.

## Adapted software

| Project | License | What we adapted |
|---|---|---|
| [8tp/startpage](https://github.com/8tp/startpage) | MIT | Zero-build launcher: config-driven groups, `!bang` parser, Open-Meteo weather, theme |
| [leecorbin/start-page](https://github.com/leecorbin/start-page) | MIT | Single-file omnibox behaviour |
| [kdippan/github-repository-analyzer](https://github.com/kdippan/github-repository-analyzer) | MIT | Client-side GitHub REST usage, optional token in `localStorage` |
| [debba/gh-dashboard (gitdeck)](https://github.com/debba/gh-dashboard) | MIT | Repository data model / per-repo field selection |
| [amruth112/CruxNews-OpenNews](https://github.com/amruth112/CruxNews-OpenNews) | MIT | *(news module, planned)* browser-side clustering + CORS-proxy architecture |
| [Greg-2600/memory-whole](https://github.com/Greg-2600/memory-whole) | MIT | *(news module, planned)* TF-IDF clustering, blindspot/framing detection |

Because Crypt Dashboard is AGPL-3.0-or-later, incorporating MIT-licensed material
is permitted (MIT is permissive and AGPL-compatible). Adapted material remains
available under its original terms below.

The standard MIT text that applies to the MIT-licensed projects above:

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Each upstream project's own LICENSE file is authoritative for its copyright
notice.

## Runtime services (not bundled)

The app calls these directly from the browser; no code or data is redistributed:

- **Google** — Identity (OAuth), Drive API, Generative Language API (Gemini).
- **GitHub** — REST API.
- **Open-Meteo** — weather (keyless).
- **Google favicon service** — favicons.
- **News CORS proxy** *(news module, planned)* — operator-configurable; fetches
  RSS only and stores nothing.

**Licensing questions?** Open an issue on the repository.
