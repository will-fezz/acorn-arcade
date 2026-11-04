#!/usr/bin/env python3
"""Generate app artwork directly from published GPK tiles (no app icon list to maintain).
Usage: generate-remote-icons.py REPOSITORY_DIRECTORY
Run on each catalogue/pack change. Never needs the release signing private key.
"""
import hashlib, io, json, struct, sys, zlib
from pathlib import Path
from PIL import Image

root = Path(sys.argv[1])
catalogue = json.loads((root / 'catalogue.json').read_text())
output = root / 'app-artwork'
(output / 'icons').mkdir(parents=True, exist_ok=True)
icons = {}

def entries(pack):
    # Catalogue hashes bind the artwork extraction to exactly the released pack.
    data = (root / 'packs' / pack['url'].rsplit('/', 1)[-1]).read_bytes()
    assert len(data) == pack['size'] and hashlib.sha256(data).hexdigest() == pack['sha256']
    magic, fmt, engine, pid, version, size, count, kind, theme = struct.unpack('<4sHH24sIIII16s', data[:64])
    assert magic == b'GPK1' and size == len(data) - 128 and count <= 5000
    for i in range(count):
        name, typ, _, width, height, _, offset, length = struct.unpack_from('<24sBBHHHII', data, 128 + i * 40)
        name = name.rstrip(b'\0').decode()
        if not (name.startswith('ui/tile_') or name.endswith('/_tile')): continue
        assert 0 < width <= 1024 and 0 < height <= 1024 and offset >= count * 40 and offset + length <= size
        pixels = data[128 + offset:128 + offset + length]
        if typ in (4, 5): pixels = zlib.decompress(pixels); typ -= 3
        assert typ in (1, 2)
        n = width * height
        assert len(pixels) == n * (3 if typ == 2 else 2)
        rgba = bytearray(n * 4)
        for p in range(n):
            v = pixels[p * 2] | pixels[p * 2 + 1] << 8
            r, g, b = v >> 11, (v >> 5) & 63, v & 31
            rgba[p*4:p*4+4] = bytes(((r << 3) | (r >> 2), (g << 2) | (g >> 4), (b << 3) | (b >> 2), pixels[2*n+p] if typ == 2 else 255))
        image = Image.frombytes('RGBA', (width, height), bytes(rgba))
        out = io.BytesIO(); image.save(out, format='PNG', optimize=True)
        yield name, out.getvalue()

rules = {p['id'] for p in catalogue['packs'] if p['kind'] == 'rules'}
themes = [p for p in catalogue['packs'] if p['kind'] == 'theme']
def save(key, data):
    digest = hashlib.sha256(data).hexdigest()
    (output / 'icons' / (digest + '.png')).write_bytes(data)
    icons[key] = digest
for pack in themes:
    theme = pack['id'].removeprefix('theme-')
    for name, data in entries(pack):
        if name.startswith('ui/tile_') and name.removeprefix('ui/tile_') in rules:
            save(theme + '/' + name.removeprefix('ui/tile_'), data)
for pack in catalogue['packs']:
    if pack['kind'] != 'rules': continue
    for name, data in entries(pack):
        if name.endswith('/_tile'): save(name.split('/')[0] + '/' + pack['id'], data)
expected = {p['id'].removeprefix('theme-') + '/' + game for p in themes for game in rules}
assert expected <= icons.keys(), 'Missing game/theme tiles: ' + str(sorted(expected - icons.keys()))
(output / 'manifest.json').write_text(json.dumps({'schema': 1, 'icons': dict(sorted(icons.items()))}, indent=2) + '\n')
print(f'Generated {len(icons)} icons from {len(rules)} games and {len(themes)} themes')
