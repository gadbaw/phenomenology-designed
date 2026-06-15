#!/bin/bash
# Build the DESIGNED-corpus site from the Approach-A output and sync into this repo.
# Isolated build: copies generators + the approach_a_have_* data (under the names the
# generators expect) into a scratch dir, so the OLD site's data is never touched.
#
# Usage:  ./deploy.sh            then   git add -A && git commit -m update && git push
set -e
SRC="/Users/benjamingadbaw/Documents/dissertation-exploration/analysis/phenom_pilot"
PY="/Users/benjamingadbaw/Documents/dissertation-exploration/.venv/bin/python3"
REPO="$(cd "$(dirname "$0")" && pwd)"
PREFIX="approach_a_have"
BUILD="$SRC/_designed_build"

for f in "${PREFIX}_units.json" "${PREFIX}_arcs.json" "${PREFIX}_enriched.json"; do
  [ -f "$SRC/$f" ] || { echo "✗ missing $SRC/$f — run approach_a_pipeline.py first"; exit 1; }
done

rm -rf "$BUILD"; mkdir -p "$BUILD"
cp "$SRC"/*.py "$BUILD"/    # all modules — generators have a transitive dep graph (classify, analytic_filter, gen_arcs, …)
cp "$SRC"/authors.json "$BUILD"/ 2>/dev/null || echo '{}' > "$BUILD"/authors.json
cp "$SRC"/affect_map.json "$BUILD"/ 2>/dev/null || echo '{}' > "$BUILD"/affect_map.json
# designed data -> the filenames each generator reads
cp "$SRC/${PREFIX}_units.json"    "$BUILD/holistic_full_units.json"
cp "$SRC/${PREFIX}_arcs.json"     "$BUILD/holistic_full_arcs.json"
cp "$SRC/${PREFIX}_arcs.json"     "$BUILD/arcs.json"
cp "$SRC/${PREFIX}_enriched.json" "$BUILD/prototype_full_enriched.json"

cd "$BUILD"
for g in gen_explorer gen_browser gen_arcs gen_viz gen_turn gen_patterns gen_glossary; do
  "$PY" "$g.py" --share >/dev/null
done
cp index.html units.html arcs.html viz.html turn.html patterns.html guide.html "$REPO"/ 2>/dev/null || true
rm -f "$REPO/corpus.html"
echo "✓ Designed-corpus site built → $REPO"
echo "  (authors/affect for newly-acquired docs may be sparse until extract_authors.py + extract_affect.py are run on $PREFIX data)"
echo "  Next: cd $REPO && git add -A && git commit -m 'designed corpus' && git push"
