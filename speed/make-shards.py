"""Write speed/shards.json from the snapshot's catalog (catalog.json from GET /v1/catalog).
  python3 make-shards.py catalog.json pilot             one shard per player, a sample across every category
  python3 make-shards.py catalog.json full N_FF N_RT [times.json]
      every case: N_FF shards for ffmpeg, N_RT for each real-time player (libvlc, gstreamer, mpv), balanced by
      estimated seconds (times.json: mean seconds per case per player and category from the pilot; else by count)."""
import json, random, sys, collections

cat = json.load(open(sys.argv[1]))["cases"]
mode = sys.argv[2]
PLAYERS = ["ffmpeg", "libvlc", "gstreamer", "mpv"]
def category(i):  # top-level folder and container: what a case's play time mostly depends on
    top, _, rest = i.partition("/")
    return top + "/" + rest.rsplit(".", 1)[-1]
if mode == "pilot":
    rnd = random.Random(20261120)
    by = collections.defaultdict(list)
    for c in cat: by[category(c["id"])].append(c["id"])
    pick = []
    for k, ids in sorted(by.items()):
        n = 1 if len(ids) < 100 else 3 if len(ids) < 1000 else 8
        pick += rnd.sample(ids, min(n, len(ids)))
    pick = sorted(set(pick) - {c["id"] for c in cat if c["id"].startswith("duration/")})
    shards = [{"player": p, "name": "pilot", "cases": pick} for p in PLAYERS]
else:
    n_ff, n_rt = int(sys.argv[3]), int(sys.argv[4])
    times = json.load(open(sys.argv[5])) if len(sys.argv) > 5 else {}
    shards = []
    for p in PLAYERS:
        n = n_ff if p == "ffmpeg" else n_rt
        t = times.get(p, {})
        dflt = t.get("*", 1.0)
        est = sorted(((t.get(category(c["id"]), dflt) * (60 if c["id"].startswith("duration/") and p != "ffmpeg" else 1), c["id"]) for c in cat), reverse=True)
        bins = [[0.0, []] for _ in range(n)]
        for s, i in est:  # longest first into the lightest bin
            b = min(bins, key=lambda x: x[0]); b[0] += s; b[1].append(i)
        for k, (s, ids) in enumerate(bins):
            shards.append({"player": p, "name": f"s{k + 1:02}", "estimate_s": round(s), "cases": sorted(ids)})
json.dump({"snapshot": "2026-11-13", "shards": shards}, open("speed/shards.json", "w"), indent=1)
print(mode, len(shards), "shards;", ", ".join(f"{s['player']} {s['name']} {len(s['cases'])}" for s in shards[:6]), "...")
