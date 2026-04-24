# ProjectPotato Extracted Assets

These files are first-pass raster assets extracted from the generated flattened mockup in [resources/source/projectpotato_mockup.png](/C:/Projects/ProjectPotato/resources/source/projectpotato_mockup.png).

Notes:

- They are intended as reusable placeholders so the Qt6 Widgets UI can visually track the mockup more closely during Phase 1.
- They are not final production art and will likely need coordinate tuning, cleanup, or replacement with hand-authored assets later.
- Hover variants are generated procedurally by the extraction script, not manually painted.
- Border slices are extracted for practical Qt use first, not perfect lossless reconstruction.

Regenerate them with:

```powershell
& 'C:\Program Files\PostgreSQL\18\pgAdmin 4\python\python.exe' tools\extract_mockup_assets.py
```
