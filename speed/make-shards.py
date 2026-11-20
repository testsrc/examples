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
    # Estimates from the pilot (run 44716004500, 145 cases): ffmpeg 2.1 s a case (most of it the download), the
    # real-time players 6.5 s a case for a 6 s file; a longer file plays for its duration. Long files by duration:
    n_ff, n_rt = int(sys.argv[3]), int(sys.argv[4])
    LONG = {"edge/flac-5-hours.flac": 18000, "duration/30m.mp4": 1800, "duration/10m.mp4": 600, "duration/5m.mp4": 300,
            "duration/1m.mp4": 60, "duration/30s.mp4": 30}
    def est(p, c):
        d = LONG.get(c["id"], 60 if "ts-vbr-long" in c["id"] else 6)
        return 2.1 + c["size_bytes"] / 20e6 if p == "ffmpeg" else d + 1.5 + c["size_bytes"] / 20e6
    shards = []
    for p in PLAYERS:
        n = n_ff if p == "ffmpeg" else n_rt
        items = sorted(((est(p, c), c["id"]) for c in cat), reverse=True)
        bins = [[0.0, []] for _ in range(n)]
        for e, i in items:  # longest first into the lightest bin
            b = min(bins, key=lambda x: x[0]); b[0] += e; b[1].append(i)
        for k, (e, ids) in enumerate(bins):
            shards.append({"player": p, "name": f"s{k + 1:02}", "estimate_s": round(e), "cases": sorted(ids)})
    shards.sort(key=lambda s: -s["estimate_s"])  # the longest jobs start first
json.dump({"snapshot": "2026-11-13", "shards": shards}, open("speed/shards.json", "w"), indent=1)
print(mode, len(shards), "shards; longest", [(s["player"], s["name"], s["estimate_s"], len(s["cases"])) for s in shards[:5]],
      "shortest", [(s["player"], s["name"], s["estimate_s"]) for s in shards[-2:]])
print("job-hours", round(sum(s["estimate_s"] for s in shards) / 3600, 1), "cases per player",
      {p: sum(len(s["cases"]) for s in shards if s["player"] == p) for p in PLAYERS})
