extends Node3D
## Barry's Barn: grow crops, raise animals, make goods, sell to passing cars.
## Everything (world, models, UI, sounds) is built in code.

const ITEMS := {
	"wheat": {"n": "Wheat", "p": 3, "c": Color(0.95, 0.8, 0.3)},
	"carrot": {"n": "Carrot", "p": 6, "c": Color(1.0, 0.5, 0.1)},
	"corn": {"n": "Corn", "p": 10, "c": Color(1.0, 0.88, 0.2)},
	"pumpkin": {"n": "Pumpkin", "p": 18, "c": Color(1.0, 0.45, 0.05)},
	"egg": {"n": "Egg", "p": 6, "c": Color(1.0, 0.96, 0.88)},
	"milk": {"n": "Milk", "p": 12, "c": Color(0.96, 0.97, 1.0)},
	"bacon": {"n": "Bacon", "p": 24, "c": Color(0.85, 0.35, 0.3)},
	"flour": {"n": "Flour", "p": 11, "c": Color(0.98, 0.95, 0.85)},
	"juice": {"n": "Carrot Juice", "p": 20, "c": Color(1.0, 0.6, 0.2)},
	"cheese": {"n": "Cheese", "p": 34, "c": Color(1.0, 0.85, 0.3)},
	"bread": {"n": "Bread", "p": 28, "c": Color(0.85, 0.6, 0.35)},
	"popcorn": {"n": "Popcorn", "p": 32, "c": Color(1.0, 0.98, 0.8)},
	"pie": {"n": "Pumpkin Pie", "p": 85, "c": Color(0.95, 0.55, 0.2)},
}
const ITEM_ORDER := ["wheat", "carrot", "corn", "pumpkin", "egg", "milk", "bacon", "flour", "juice", "cheese", "bread", "popcorn", "pie"]
const CROP_ORDER := ["wheat", "carrot", "corn", "pumpkin"]
const CROPS := {
	"wheat": {"t": 8.0, "lvl": 1, "seed": 0},
	"carrot": {"t": 14.0, "lvl": 2, "seed": 2},
	"corn": {"t": 22.0, "lvl": 4, "seed": 4},
	"pumpkin": {"t": 35.0, "lvl": 6, "seed": 7},
}
const STATION_ORDER := ["mill", "juicer", "dairy", "bakery", "popper", "oven"]
const STATIONS := {
	"mill": {"n": "Mill", "in": {"wheat": 2}, "out": "flour", "t": 6.0, "cost": 40, "lvl": 1, "c": Color(0.85, 0.75, 0.55)},
	"juicer": {"n": "Juicer", "in": {"carrot": 2}, "out": "juice", "t": 8.0, "cost": 120, "lvl": 2, "c": Color(1.0, 0.65, 0.3)},
	"dairy": {"n": "Dairy", "in": {"milk": 2}, "out": "cheese", "t": 12.0, "cost": 220, "lvl": 3, "c": Color(0.75, 0.85, 1.0)},
	"bakery": {"n": "Bakery", "in": {"flour": 1, "egg": 1}, "out": "bread", "t": 10.0, "cost": 300, "lvl": 4, "c": Color(0.95, 0.8, 0.6)},
	"popper": {"n": "Popcorn Pot", "in": {"corn": 2}, "out": "popcorn", "t": 8.0, "cost": 380, "lvl": 5, "c": Color(1.0, 0.95, 0.5)},
	"oven": {"n": "Pie Oven", "in": {"pumpkin": 1, "flour": 1, "egg": 1}, "out": "pie", "t": 16.0, "cost": 800, "lvl": 7, "c": Color(0.8, 0.45, 0.35)},
}
const ANIMAL_ORDER := ["chicken", "cow", "pig"]
## h = height the ready product floats at, spd = walk speed.
const ANIMALS := {
	"chicken": {"n": "Chicken", "out": "egg", "t": 12.0, "cost": 40, "lvl": 1, "max": 6, "h": 1.5, "spd": 1.4},
	"cow": {"n": "Cow", "out": "milk", "t": 20.0, "cost": 150, "lvl": 3, "max": 4, "h": 2.4, "spd": 0.7},
	"pig": {"n": "Pig", "out": "bacon", "t": 26.0, "cost": 260, "lvl": 5, "max": 4, "h": 1.7, "spd": 0.9},
}
const UPGRADE_ORDER := ["farmhand", "collector", "chef", "seller", "fert", "feed", "sign", "fame"]
const UPGRADES := {
	"farmhand": {"n": "Scarecrow Farmhand", "d": "Harvests ripe crops for you", "cost": 120, "max": 3},
	"collector": {"n": "Barn Robot", "d": "Collects eggs and milk for you", "cost": 150, "max": 3},
	"chef": {"n": "Kitchen Helper", "d": "Runs your stations for you", "cost": 250, "max": 3},
	"seller": {"n": "Stand Clerk", "d": "Sells to cars for you", "cost": 200, "max": 3},
	"fert": {"n": "Fertilizer", "d": "Crops grow 15% faster", "cost": 60, "max": 5},
	"feed": {"n": "Tasty Feed", "d": "Animals produce 15% faster", "cost": 90, "max": 5},
	"sign": {"n": "Big Billboard", "d": "Customers arrive sooner", "cost": 80, "max": 5},
	"fame": {"n": "Good Reviews", "d": "Customers pay 10% more", "cost": 120, "max": 5},
}
const HELPERS := ["farmhand", "collector", "chef", "seller"]
## Seconds between helper actions for upgrade levels 0..3 (0 = not hired).
const HELPER_INTERVAL := [0.0, 5.0, 2.5, 1.0]
const SAVE_PATH := "user://barrys_barn.json"
const PLOT_COUNT := 16
const STAND_X := 6.0
const LANE_Z := 10.2
const PEN_MIN := Vector2(0.8, -9.4)
const PEN_MAX := Vector2(9.2, -3.8)
const DIRT := Color(0.45, 0.3, 0.18)
const LOCKED_DIRT := Color(0.42, 0.5, 0.3)
const WOOD := Color(0.6, 0.4, 0.22)
const CAR_COLORS := [Color(0.9, 0.2, 0.2), Color(0.2, 0.5, 0.95), Color(1.0, 0.8, 0.1), Color(0.3, 0.8, 0.4), Color(0.7, 0.35, 0.9), Color(1.0, 0.55, 0.15), Color(0.95, 0.95, 0.95)]

# --- saved state ---
var coins := 50
var xp := 0
var level := 1
var inv := {}
var plots := []
var stations := {}
var animals := []
var upg := {"farmhand": 0, "collector": 0, "chef": 0, "seller": 0, "fert": 0, "feed": 0, "sign": 0, "fame": 0}
var muted := false
var helper_timers := {}
var resetting := false
var pause_panel: PanelContainer
var help_title: Label
var help_body: Label
var help_page_lbl: Label
var help_prev: Button
var help_next: Button
var help_page := 0
var reset_btn: Button
var mute_btn: Button
var sel_crop := "wheat"
var seen_help := false

# --- runtime ---
var mats := {}
var cam: Camera3D
var cam_target := Vector3(-1, 0, 3.0)
var cam_zoom := 1.2
var press_pos := Vector2.ZERO
var pressing := false
var dragging := false
var plot_nodes := []
var station_nodes := {}
var animal_nodes := []
var cars := []
var helper_nodes := {}
var ambient := []
var car_timer := 3.0
var ambient_timer := 2.0
var save_timer := 5.0
var ui_timer := 0.0
var clock := 0.0
var sfx := {}

var ui_coins: Label
var ui_level: Label
var ui_xp: ProgressBar
var ui_inv: Label
var ui_toast: Label
var seed_box: VBoxContainer
var upg_panel: PanelContainer
var upg_box: VBoxContainer
var help_panel: PanelContainer
var toast_tween: Tween


func _ready() -> void:
	randomize()
	new_game_state()
	load_game()
	build_sounds()
	build_world()
	build_ui()
	for i in PLOT_COUNT:
		refresh_plot(i)
	for id in STATION_ORDER:
		refresh_station(id)
	for i in animals.size():
		spawn_animal_node(i)
	refresh_pen_signs()
	refresh_helpers()
	refresh_ui()
	if not seen_help:
		show_help(0)


func new_game_state() -> void:
	plots.clear()
	for i in PLOT_COUNT:
		plots.append({"open": i < 4, "crop": "", "t": 0.0})
	for id in STATION_ORDER:
		stations[id] = {"own": false, "busy": false, "t": 0.0, "ready": 0}
	animals = [{"type": "chicken", "t": 0.0}]
	inv = {}


# ================= helpers =================

func mat(c: Color, metal := 0.0, glow := false) -> StandardMaterial3D:
	var key := [c, metal, glow]
	if mats.has(key):
		return mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.35 if metal > 0.0 else 0.75
	m.metallic = metal
	if glow:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = 2.0
	mats[key] = m
	return m


## Re-skins a part with a shiny metal or glowing material.
func skin(mi: MeshInstance3D, c: Color, metal := 0.0, glow := false) -> MeshInstance3D:
	mi.material_override = mat(c, metal, glow)
	return mi


func box(parent: Node, size: Vector3, pos: Vector3, c: Color) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = size
	return add_mesh(parent, bm, pos, c)


func cyl(parent: Node, r_top: float, r_bot: float, h: float, pos: Vector3, c: Color, seg := 12) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = r_top
	cm.bottom_radius = r_bot
	cm.height = h
	cm.radial_segments = seg
	cm.rings = 1
	return add_mesh(parent, cm, pos, c)


func sph(parent: Node, r: float, pos: Vector3, c: Color, sc := Vector3.ONE) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 16
	sm.rings = 8
	var mi := add_mesh(parent, sm, pos, c)
	mi.scale = sc
	return mi


func prism(parent: Node, size: Vector3, pos: Vector3, c: Color) -> MeshInstance3D:
	var pm := PrismMesh.new()
	pm.size = size
	return add_mesh(parent, pm, pos, c)


func add_mesh(parent: Node, mesh: Mesh, pos: Vector3, c: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(c)
	mi.position = pos
	parent.add_child(mi)
	return mi


func label3d(parent: Node, text: String, pos: Vector3, size := 44, billboard := true) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.outline_size = 10
	l.pixel_size = 0.01
	l.position = pos
	l.no_depth_test = true
	l.render_priority = 5
	l.outline_render_priority = 4
	if billboard:
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(l)
	return l


func add_hit(parent: Node3D, size: Vector3, center: Vector3, kind: String, id: Variant) -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.position = center
	body.add_child(shape)
	body.set_meta("kind", kind)
	body.set_meta("id", id)
	parent.add_child(body)


func node_at(parent: Node, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	parent.add_child(n)
	return n


func bounce(n: Node3D) -> void:
	n.scale = Vector3.ONE * 1.2
	var tw := create_tween()
	tw.tween_property(n, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func float_text(pos: Vector3, text: String, c := Color.WHITE) -> void:
	var l := label3d(self, text, pos + Vector3(0, 1.5, 0), 64)
	l.modulate = c
	var tw := create_tween().set_parallel(true)
	tw.tween_property(l, "position", l.position + Vector3(0, 2.2, 0), 1.1)
	tw.tween_property(l, "modulate:a", 0.0, 0.6).set_delay(0.5)
	tw.chain().tween_callback(l.queue_free)


func item_name(id: String) -> String:
	return ITEMS[id]["n"]


func have(id: String) -> int:
	return int(inv.get(id, 0))


func add_item(id: String, n: int) -> void:
	inv[id] = have(id) + n
	refresh_ui()


func recipe_text(ins: Dictionary) -> String:
	var parts := []
	for k in ins:
		parts.append("%d %s" % [ins[k], item_name(k)])
	return " + ".join(parts)


# ================= sounds =================

func build_sounds() -> void:
	sfx["pop"] = make_tone([660.0, 880.0], 0.12)
	sfx["coin"] = make_tone([988.0, 1319.0], 0.25)
	sfx["nope"] = make_tone([220.0, 180.0], 0.18)
	sfx["build"] = make_tone([523.0, 659.0, 784.0], 0.3)
	sfx["level"] = make_tone([523.0, 659.0, 784.0, 1047.0], 0.6)
	for k in sfx.keys():
		var p := AudioStreamPlayer.new()
		p.stream = sfx[k]
		p.volume_db = -6.0
		add_child(p)
		sfx[k] = p


func make_tone(freqs: Array, dur: float) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var f: float = freqs[mini(int(t / dur * freqs.size()), freqs.size() - 1)]
		var env := (1.0 - t / dur) * minf(1.0, t * 200.0)
		data.encode_s16(i * 2, int(sin(TAU * f * t) * env * 0.3 * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.data = data
	return w


func play(name: String) -> void:
	var p: AudioStreamPlayer = sfx[name]
	p.play()


# ================= world =================

func build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.32, 0.6, 0.95)
	sky_mat.sky_horizon_color = Color(0.75, 0.88, 1.0)
	sky_mat.ground_horizon_color = Color(0.6, 0.75, 0.55)
	sky_mat.ground_bottom_color = Color(0.3, 0.45, 0.25)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.85, 0.88, 1.0)
	e.ambient_light_energy = 0.35
	e.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_energy = 1.15
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60.0
	add_child(sun)

	cam = Camera3D.new()
	cam.fov = 45.0
	add_child(cam)
	update_camera()

	# ground, road
	box(self, Vector3(140, 1, 120), Vector3(0, -0.5, 0), Color(0.36, 0.64, 0.26))
	box(self, Vector3(140, 0.06, 4.6), Vector3(0, 0.03, 11.2), Color(0.3, 0.3, 0.33))
	for i in 28:
		box(self, Vector3(1.8, 0.07, 0.18), Vector3(-67 + i * 5, 0.04, 11.2), Color(1, 0.95, 0.6))
	box(self, Vector3(140, 0.08, 0.3), Vector3(0, 0.04, 8.9), Color(0.85, 0.85, 0.8))

	build_barn()
	build_stand()
	build_pen()
	build_decor()

	# plots
	for i in PLOT_COUNT:
		var root := node_at(self, plot_pos(i))
		var dirt := box(root, Vector3(2.2, 0.25, 2.2), Vector3(0, 0.12, 0), DIRT)
		var lbl := label3d(root, "", Vector3(0, 1.0, 0), 40)
		add_hit(root, Vector3(2.4, 1.6, 2.4), Vector3(0, 0.8, 0), "plot", i)
		plot_nodes.append({"root": root, "dirt": dirt, "label": lbl, "crop": null})

	# stations
	for i in STATION_ORDER.size():
		var id: String = STATION_ORDER[i]
		var root := node_at(self, station_pos(i))
		var pad := box(root, Vector3(3.0, 0.1, 2.6), Vector3(0, 0.05, 0), Color(0.7, 0.68, 0.6))
		var bld := node_at(root, Vector3.ZERO)
		build_station_model(id, bld)
		var lbl := label3d(root, "", Vector3(0, 3.6, 0), 36)
		add_hit(root, Vector3(3.0, 3.0, 2.6), Vector3(0, 1.5, 0), "station", id)
		station_nodes[id] = {"root": root, "pad": pad, "bld": bld, "label": lbl, "spin": bld.get_node_or_null("Spin")}


func plot_pos(i: int) -> Vector3:
	return Vector3(-14.0 + (i % 4) * 2.6, 0, -6.5 + int(i / 4.0) * 2.6)


func station_pos(i: int) -> Vector3:
	return Vector3(-3.0 + i * 3.6, 0, 3.0)


func build_barn() -> void:
	var b := node_at(self, Vector3(-10, 0, -14))
	var red := Color(0.75, 0.15, 0.12)
	box(b, Vector3(7, 4, 5.5), Vector3(0, 2, 0), red)
	box(b, Vector3(7.2, 0.3, 5.7), Vector3(0, 0.15, 0), Color(0.5, 0.45, 0.42))
	prism(b, Vector3(7.6, 2.4, 6), Vector3(0, 5.2, 0), Color(0.35, 0.3, 0.3))
	prism(b, Vector3(7.0, 2.0, 5.5), Vector3(0, 5.0, 0.02), red)
	# white trim on corners and gable
	for x in [-3.5, 3.5]:
		for zz in [-2.75, 2.75]:
			box(b, Vector3(0.22, 4.0, 0.22), Vector3(x, 2, zz), Color.WHITE)
	box(b, Vector3(7.2, 0.22, 0.22), Vector3(0, 4.0, 2.78), Color.WHITE)
	box(b, Vector3(2.9, 3.2, 0.12), Vector3(0, 1.6, 2.78), Color.WHITE)
	box(b, Vector3(2.6, 3, 0.1), Vector3(0, 1.5, 2.82), Color(0.55, 0.1, 0.08))
	box(b, Vector3(2.8, 0.2, 0.15), Vector3(0, 1.5, 2.88), Color.WHITE).rotation_degrees.z = 48
	box(b, Vector3(2.8, 0.2, 0.15), Vector3(0, 1.5, 2.88), Color.WHITE).rotation_degrees.z = -48
	# hayloft window
	box(b, Vector3(1.3, 1.1, 0.1), Vector3(0, 5.0, 2.78), Color.WHITE)
	box(b, Vector3(1.0, 0.8, 0.1), Vector3(0, 5.0, 2.82), Color(0.25, 0.15, 0.1))
	sph(b, 0.45, Vector3(0, 4.85, 2.85), Color(0.95, 0.85, 0.35), Vector3(1.4, 0.6, 0.4))
	var sign_l := label3d(b, "BARRY'S BARN", Vector3(0, 4.25, 3.1), 90, false)
	sign_l.modulate = Color(1, 0.95, 0.7)
	# silo with bands and dome
	skin(cyl(b, 1.3, 1.3, 7, Vector3(5.2, 3.5, -0.5), Color(0.78, 0.78, 0.82), 20), Color(0.78, 0.78, 0.82), 0.5)
	for h in [1.2, 3.0, 4.8, 6.6]:
		skin(cyl(b, 1.34, 1.34, 0.12, Vector3(5.2, h, -0.5), Color(0.55, 0.58, 0.62), 20), Color(0.55, 0.58, 0.62), 0.6)
	skin(sph(b, 1.3, Vector3(5.2, 7, -0.5), Color(0.5, 0.55, 0.65)), Color(0.5, 0.55, 0.65), 0.6)
	# hay bales
	for hp in [Vector3(-4.6, 0.45, 2.2), Vector3(-4.6, 0.45, 1.0), Vector3(-4.6, 1.3, 1.6)]:
		cyl(b, 0.45, 0.45, 1.0, hp, Color(0.92, 0.8, 0.4), 14).rotation_degrees.x = 90


func build_stand() -> void:
	var s := node_at(self, Vector3(STAND_X, 0, 7.6))
	box(s, Vector3(3.4, 1.1, 1.0), Vector3(0, 0.55, 0), WOOD)
	box(s, Vector3(3.6, 0.12, 1.2), Vector3(0, 1.15, 0), Color(0.75, 0.55, 0.3))
	for x in [-1.6, 1.6]:
		box(s, Vector3(0.15, 2.8, 0.15), Vector3(x, 1.4, -0.4), WOOD)
	for i in 6:
		var c := Color(0.9, 0.2, 0.2) if i % 2 == 0 else Color.WHITE
		box(s, Vector3(0.62, 0.12, 1.5), Vector3(-1.55 + i * 0.62, 2.85, 0.1), c).rotation_degrees.x = 15
	for i in 3:
		box(s, Vector3(0.6, 0.35, 0.5), Vector3(-1.0 + i * 1.0, 1.4, 0), [Color(1, 0.5, 0.1), Color(0.95, 0.8, 0.3), Color(0.9, 0.2, 0.2)][i])
	var l := label3d(s, "FARM STAND", Vector3(0, 3.4, 0.2), 60, false)
	l.modulate = Color(1, 0.9, 0.4)


func build_pen() -> void:
	var p := node_at(self, Vector3.ZERO)
	var x0 := PEN_MIN.x - 0.6
	var x1 := PEN_MAX.x + 0.6
	var z0 := PEN_MIN.y - 0.6
	var z1 := PEN_MAX.y + 0.6
	var posts := []
	var x := x0
	while x <= x1 + 0.01:
		posts.append(Vector3(x, 0, z0))
		posts.append(Vector3(x, 0, z1))
		x += 1.5
	var z := z0
	while z <= z1 + 0.01:
		posts.append(Vector3(x0, 0, z))
		posts.append(Vector3(x1, 0, z))
		z += 1.5
	for pt in posts:
		box(p, Vector3(0.18, 1.0, 0.18), pt + Vector3(0, 0.5, 0), Color.WHITE)
	for h in [0.4, 0.8]:
		box(p, Vector3(x1 - x0, 0.1, 0.08), Vector3((x0 + x1) / 2, h, z0), Color.WHITE)
		box(p, Vector3(x1 - x0, 0.1, 0.08), Vector3((x0 + x1) / 2, h, z1), Color.WHITE)
		box(p, Vector3(0.08, 0.1, z1 - z0), Vector3(x0, h, (z0 + z1) / 2), Color.WHITE)
		box(p, Vector3(0.08, 0.1, z1 - z0), Vector3(x1, h, (z0 + z1) / 2), Color.WHITE)
	box(p, Vector3(x1 - x0, 0.04, z1 - z0), Vector3((x0 + x1) / 2, 0.02, (z0 + z1) / 2), Color(0.6, 0.7, 0.35))
	# trough + coop
	box(p, Vector3(2.0, 0.4, 0.6), Vector3(5, 0.2, -9.0), WOOD)
	box(p, Vector3(1.8, 0.1, 0.4), Vector3(5, 0.42, -9.0), Color(0.9, 0.8, 0.3))
	var coop := node_at(p, Vector3(1.6, 0, -8.6))
	box(coop, Vector3(1.4, 1.0, 1.0), Vector3(0, 0.7, 0), Color(0.95, 0.85, 0.6))
	prism(coop, Vector3(1.6, 0.6, 1.2), Vector3(0, 1.5, 0), Color(0.75, 0.15, 0.12))
	# buy signs
	for i in ANIMAL_ORDER.size():
		var id: String = ANIMAL_ORDER[i]
		var sn := node_at(self, Vector3(1.6 + i * 3.4, 0, -2.4))
		box(sn, Vector3(0.12, 1.2, 0.12), Vector3(0, 0.6, 0), WOOD)
		box(sn, Vector3(2.3, 1.05, 0.08), Vector3(0, 1.4, -0.02), WOOD)
		box(sn, Vector3(2.2, 0.95, 0.1), Vector3(0, 1.4, 0), Color(0.95, 0.9, 0.75))
		var l := label3d(sn, "", Vector3(0, 1.4, 0.08), 34, false)
		l.modulate = Color(0.2, 0.12, 0.05)
		l.outline_size = 0
		add_hit(sn, Vector3(1.8, 1.8, 0.8), Vector3(0, 1.0, 0), "buy_animal", id)
		sn.set_meta("label", l)
		sn.name = "Sign_" + id


func build_decor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var spots := []
	for i in 70:
		var p := Vector3(rng.randf_range(-45, 45), 0, rng.randf_range(-35, 30))
		if p.z > 6.0 and p.z < 16.0:
			continue
		if p.x > -19 and p.x < 22 and p.z > -19 and p.z < 7:
			continue
		spots.append(p)
	for p in spots:
		var t := node_at(self, p)
		var s := rng.randf_range(0.8, 1.5)
		cyl(t, 0.16 * s, 0.26 * s, 1.4 * s, Vector3(0, 0.7 * s, 0), Color(0.45, 0.3, 0.18), 8)
		if rng.randf() < 0.5:
			var pine := Color(0.16, 0.45, 0.26)
			for k in 3:
				var f := 1.0 - k * 0.25
				cyl(t, 0, 1.3 * s * f, 1.6 * s, Vector3(0, (1.7 + k * 0.85) * s, 0), pine.lightened(k * 0.06), 10)
		else:
			var leaf := Color(0.3, 0.62, 0.25)
			sph(t, 1.0 * s, Vector3(0, 2.1 * s, 0), leaf)
			sph(t, 0.75 * s, Vector3(0.6 * s, 2.5 * s, 0.2 * s), leaf.lightened(0.08))
			sph(t, 0.7 * s, Vector3(-0.55 * s, 2.4 * s, -0.3 * s), leaf.darkened(0.08))
			sph(t, 0.6 * s, Vector3(0.1 * s, 2.9 * s, -0.1 * s), leaf.lightened(0.12))
	for i in 12:
		var x := -16.0 + i * 3.4
		if x > -1.5 and x < 0.5:
			continue
		box(self, Vector3(0.15, 0.8, 0.15), Vector3(x, 0.4, 8.4), WOOD)
	box(self, Vector3(38, 0.1, 0.1), Vector3(2.7, 0.65, 8.4), WOOD)


func build_station_model(id: String, b: Node3D) -> void:
	var c: Color = STATIONS[id]["c"]
	box(b, Vector3(2.4, 1.6, 1.9), Vector3(0, 0.9, 0), c)
	box(b, Vector3(2.5, 0.2, 2.0), Vector3(0, 0.1, 0), c.darkened(0.3))
	prism(b, Vector3(2.7, 0.9, 2.2), Vector3(0, 2.15, 0), Color(0.7, 0.2, 0.15))
	box(b, Vector3(2.75, 0.08, 2.25), Vector3(0, 1.72, 0), Color.WHITE)
	box(b, Vector3(0.85, 1.12, 0.05), Vector3(0, 0.62, 0.96), Color.WHITE)
	box(b, Vector3(0.7, 1.0, 0.05), Vector3(0, 0.6, 0.98), Color(0.4, 0.25, 0.15))
	sph(b, 0.05, Vector3(0.22, 0.6, 1.02), Color(0.95, 0.8, 0.3))
	for x in [-1.21, 1.21]:
		box(b, Vector3(0.05, 0.6, 0.7), Vector3(x, 1.05, 0), Color.WHITE)
		box(b, Vector3(0.06, 0.48, 0.58), Vector3(x, 1.05, 0), Color(0.55, 0.8, 0.95))
	var spin := node_at(b, Vector3(0.75, 1.2, 1.0))
	spin.name = "Spin"
	match id:
		"mill":
			spin.position = Vector3(0, 2.2, 1.15)
			for k in 4:
				box(spin, Vector3(0.25, 1.6, 0.05), Vector3.ZERO, Color(0.95, 0.95, 0.9)).rotation_degrees.z = k * 45.0
		"juicer":
			sph(spin, 0.3, Vector3.ZERO, Color(1, 0.55, 0.1))
		"dairy":
			cyl(spin, 0.25, 0.25, 0.5, Vector3.ZERO, Color.WHITE).rotation_degrees.x = 90
		"bakery":
			cyl(b, 0.18, 0.2, 0.8, Vector3(-0.7, 2.4, 0), Color(0.5, 0.5, 0.5))
			sph(spin, 0.28, Vector3.ZERO, Color(0.85, 0.6, 0.35), Vector3(1.4, 0.7, 1))
		"popper":
			cyl(spin, 0.3, 0.2, 0.4, Vector3.ZERO, Color(0.9, 0.2, 0.2))
		"oven":
			cyl(b, 0.2, 0.2, 1.0, Vector3(0.7, 2.5, -0.3), Color(0.4, 0.3, 0.3))
			cyl(spin, 0.3, 0.3, 0.1, Vector3.ZERO, Color(0.95, 0.55, 0.2), 10).rotation_degrees.x = 90


# ================= plots =================

func open_plot_count() -> int:
	var n := 0
	for p in plots:
		if p["open"]:
			n += 1
	return n


func next_locked() -> int:
	for i in PLOT_COUNT:
		if not plots[i]["open"]:
			return i
	return -1


func plot_cost() -> int:
	return 15 + (open_plot_count() - 4) * 12


func grow_mult() -> float:
	return 1.0 + 0.15 * upg["fert"]


func refresh_plot(i: int) -> void:
	var pn: Dictionary = plot_nodes[i]
	var p: Dictionary = plots[i]
	(pn["dirt"] as MeshInstance3D).material_override = mat(DIRT if p["open"] else LOCKED_DIRT)
	if pn["crop"] != null:
		(pn["crop"] as Node3D).queue_free()
		pn["crop"] = null
	var lbl: Label3D = pn["label"]
	lbl.visible = not p["open"] and i == next_locked()
	lbl.text = "Buy Plot\n$%d" % plot_cost()
	if p["crop"] != "":
		pn["crop"] = make_crop(p["crop"], pn["root"])


func make_crop(type: String, parent: Node3D) -> Node3D:
	var c := node_at(parent, Vector3(0, 0.25, 0))
	var offs := [Vector3(-0.55, 0, -0.55), Vector3(0.55, 0, -0.55), Vector3(-0.55, 0, 0.55), Vector3(0.55, 0, 0.55), Vector3.ZERO]
	for o in offs:
		match type:
			"wheat":
				for k in 3:
					var d := Vector3((k - 1) * 0.12, 0, (k % 2) * 0.1)
					cyl(c, 0.02, 0.03, 0.8, o + d + Vector3(0, 0.4, 0), Color(0.75, 0.7, 0.3), 4)
					cyl(c, 0.05, 0.06, 0.3, o + d + Vector3(0, 0.9, 0), Color(0.95, 0.8, 0.3), 5)
			"carrot":
				cyl(c, 0.14, 0.0, 0.4, o + Vector3(0, 0.05, 0), Color(1, 0.5, 0.1), 6)
				for k in 3:
					cyl(c, 0.0, 0.06, 0.45, o + Vector3((k - 1) * 0.08, 0.45, 0), Color(0.2, 0.7, 0.2), 4).rotation_degrees.z = (k - 1) * 20.0
			"corn":
				cyl(c, 0.05, 0.08, 1.6, o + Vector3(0, 0.8, 0), Color(0.3, 0.65, 0.25), 5)
				sph(c, 0.12, o + Vector3(0.12, 1.0, 0), Color(1, 0.88, 0.2), Vector3(1, 2.2, 1))
				box(c, Vector3(0.6, 0.04, 0.12), o + Vector3(0, 1.3, 0), Color(0.35, 0.7, 0.3)).rotation_degrees.y = 40
			"pumpkin":
				if o == Vector3.ZERO:
					continue
				sph(c, 0.32, o + Vector3(0, 0.22, 0), Color(1, 0.45, 0.05), Vector3(1.2, 0.8, 1.2))
				cyl(c, 0.04, 0.05, 0.2, o + Vector3(0, 0.5, 0), Color(0.3, 0.5, 0.2), 4)
	c.scale = Vector3.ONE * 0.25
	return c


func tap_plot(i: int) -> void:
	var p: Dictionary = plots[i]
	var pos := plot_pos(i)
	if not p["open"]:
		if i != next_locked():
			toast("Buy the glowing plot first")
			play("nope")
			return
		var cost := plot_cost()
		if coins < cost:
			toast("Need $%d to buy this plot" % cost)
			play("nope")
			return
		coins -= cost
		p["open"] = true
		play("build")
		float_text(pos, "New plot!", Color(0.6, 1, 0.6))
		refresh_plot(i)
		var nl := next_locked()
		if nl >= 0:
			refresh_plot(nl)
		bounce(plot_nodes[i]["root"])
		refresh_ui()
		return
	if p["crop"] == "":
		plant(i)
		return
	var need: float = CROPS[p["crop"]]["t"]
	if p["t"] >= need:
		var crop: String = p["crop"]
		add_item(crop, 2)
		gain_xp(1)
		play("pop")
		float_text(pos, "+2 " + item_name(crop), ITEMS[crop]["c"])
		p["crop"] = ""
		refresh_plot(i)
		bounce(plot_nodes[i]["root"])
		plant(i, true)
	else:
		toast("%s ready in %ds" % [item_name(p["crop"]), ceili((need - p["t"]) / grow_mult())])


func plant(i: int, quiet := false) -> void:
	var p: Dictionary = plots[i]
	var cost: int = CROPS[sel_crop]["seed"]
	if coins < cost:
		if not quiet:
			toast("Seeds cost $%d" % cost)
			play("nope")
		return
	coins -= cost
	p["crop"] = sel_crop
	p["t"] = 0.0
	refresh_plot(i)
	if not quiet:
		play("pop")
	refresh_ui()


# ================= stations =================

func station_can_start(id: String) -> bool:
	var ins: Dictionary = STATIONS[id]["in"]
	for k in ins:
		if have(k) < ins[k]:
			return false
	return true


func station_start(id: String) -> void:
	var ins: Dictionary = STATIONS[id]["in"]
	for k in ins:
		inv[k] = have(k) - ins[k]
	stations[id]["busy"] = true
	stations[id]["t"] = 0.0
	refresh_ui()


func refresh_station(id: String) -> void:
	var sn: Dictionary = station_nodes[id]
	var s: Dictionary = stations[id]
	var st: Dictionary = STATIONS[id]
	(sn["bld"] as Node3D).visible = s["own"]
	var lbl: Label3D = sn["label"]
	if not s["own"]:
		lbl.position.y = 1.4
		if level < st["lvl"]:
			lbl.text = "%s\nLevel %d" % [st["n"], st["lvl"]]
			lbl.modulate = Color(0.8, 0.8, 0.8)
		else:
			lbl.text = "Build %s\n$%d" % [st["n"], st["cost"]]
			lbl.modulate = Color(1, 0.95, 0.6) if coins >= st["cost"] else Color(1, 0.7, 0.6)
		return
	lbl.position.y = 3.4
	var status := ""
	if s["ready"] > 0:
		status = "TAP: %d %s ready!" % [s["ready"], item_name(st["out"])]
		lbl.modulate = Color(0.6, 1, 0.6)
	elif s["busy"]:
		status = "Making... %ds" % ceili(st["t"] - s["t"])
		lbl.modulate = Color.WHITE
	elif station_can_start(id):
		status = "Tap to start"
		lbl.modulate = Color(1, 0.95, 0.6)
	else:
		status = "Needs " + recipe_text(st["in"])
		lbl.modulate = Color(0.85, 0.85, 0.85)
	lbl.text = "%s\n%s > %s\n%s" % [st["n"], recipe_text(st["in"]), item_name(st["out"]), status]


func tap_station(id: String) -> void:
	var s: Dictionary = stations[id]
	var st: Dictionary = STATIONS[id]
	var pos: Vector3 = station_nodes[id]["root"].position
	if not s["own"]:
		if level < st["lvl"]:
			toast("%s unlocks at level %d" % [st["n"], st["lvl"]])
			play("nope")
		elif coins < st["cost"]:
			toast("Need $%d to build %s" % [st["cost"], st["n"]])
			play("nope")
		else:
			coins -= st["cost"]
			s["own"] = true
			play("build")
			float_text(pos, st["n"] + " built!", Color(0.6, 1, 0.6))
			refresh_station(id)
			bounce(station_nodes[id]["bld"])
			refresh_ui()
		return
	if s["ready"] > 0:
		var n: int = s["ready"]
		s["ready"] = 0
		add_item(st["out"], n)
		gain_xp(2 * n)
		play("pop")
		float_text(pos + Vector3(0, 1.5, 0), "+%d %s" % [n, item_name(st["out"])], ITEMS[st["out"]]["c"])
		bounce(station_nodes[id]["bld"])
		if not s["busy"] and station_can_start(id):
			station_start(id)
	elif s["busy"]:
		toast("%s is working..." % st["n"])
	elif station_can_start(id):
		station_start(id)
		play("pop")
		bounce(station_nodes[id]["bld"])
	else:
		toast("%s needs %s" % [st["n"], recipe_text(st["in"])])
		play("nope")
	refresh_station(id)


# ================= animals =================

func animal_count(type: String) -> int:
	var n := 0
	for a in animals:
		if a["type"] == type:
			n += 1
	return n


func animal_cost(type: String) -> int:
	return int(ANIMALS[type]["cost"] * (1.0 + animal_count(type) * 0.6))


func feed_mult() -> float:
	return 1.0 + 0.15 * upg["feed"]


func spawn_animal_node(i: int) -> void:
	var type: String = animals[i]["type"]
	var n := Node3D.new()
	add_child(n)
	n.position = Vector3(randf_range(PEN_MIN.x, PEN_MAX.x), 0, randf_range(PEN_MIN.y, PEN_MAX.y))
	var body := node_at(n, Vector3.ZERO)
	var ad: Dictionary = ANIMALS[type]
	var prod := node_at(n, Vector3(0, ad["h"], 0))
	match type:
		"chicken":
			build_chicken(body, prod)
			add_hit(n, Vector3(1.2, 1.6, 1.2), Vector3(0, 0.7, 0), "animal", i)
		"cow":
			build_cow(body, prod)
			add_hit(n, Vector3(1.4, 2.0, 2.2), Vector3(0, 1.0, 0), "animal", i)
		"pig":
			build_pig(body, prod)
			add_hit(n, Vector3(1.3, 1.5, 1.9), Vector3(0, 0.7, 0), "animal", i)
	prod.visible = false
	animal_nodes.append({"node": n, "body": body, "prod": prod, "target": n.position, "wait": randf() * 2.0})


func build_chicken(b: Node3D, prod: Node3D) -> void:
	var orange := Color(1, 0.6, 0.1)
	var red := Color(0.9, 0.12, 0.1)
	sph(b, 0.3, Vector3(0, 0.48, -0.02), Color.WHITE, Vector3(1, 0.9, 1.25))
	sph(b, 0.2, Vector3(0, 0.68, -0.3), Color(0.97, 0.97, 0.95), Vector3(0.7, 1.3, 0.8)).rotation_degrees.x = -30
	for x in [-0.27, 0.27]:
		sph(b, 0.16, Vector3(x, 0.5, -0.02), Color(0.93, 0.93, 0.9), Vector3(0.35, 0.8, 1.3))
	sph(b, 0.17, Vector3(0, 0.82, 0.26), Color.WHITE)
	for k in 3:
		sph(b, 0.055, Vector3(0, 1.0 + (1 - absf(k - 1)) * 0.03, 0.2 + k * 0.07), red)
	sph(b, 0.05, Vector3(0, 0.68, 0.4), red, Vector3(0.7, 1.4, 0.7))
	cyl(b, 0.0, 0.055, 0.13, Vector3(0, 0.8, 0.47), orange, 8).rotation_degrees.x = 90
	for x in [-0.1, 0.1]:
		sph(b, 0.035, Vector3(x, 0.86, 0.39), Color(0.05, 0.05, 0.05))
		cyl(b, 0.025, 0.025, 0.28, Vector3(x, 0.14, 0), orange, 6)
		box(b, Vector3(0.1, 0.02, 0.14), Vector3(x, 0.01, 0.04), orange)
	sph(prod, 0.16, Vector3.ZERO, Color(1, 0.96, 0.88), Vector3(1, 1.3, 1))


func build_cow(b: Node3D, prod: Node3D) -> void:
	var black := Color(0.12, 0.12, 0.12)
	var pink := Color(1, 0.72, 0.76)
	sph(b, 0.55, Vector3(0, 1.05, 0), Color.WHITE, Vector3(0.85, 0.75, 1.5))
	sph(b, 0.3, Vector3(0.38, 1.15, 0.2), black, Vector3(0.25, 0.9, 1.1))
	sph(b, 0.25, Vector3(-0.38, 1.05, -0.35), black, Vector3(0.25, 0.9, 1.1))
	sph(b, 0.24, Vector3(0.05, 1.42, -0.4), black, Vector3(1.1, 0.25, 1.0))
	# head
	sph(b, 0.3, Vector3(0, 1.38, 0.95), Color.WHITE, Vector3(0.95, 1.0, 1.15))
	sph(b, 0.22, Vector3(0, 1.24, 1.22), pink, Vector3(1.1, 0.8, 0.8))
	for x in [-0.08, 0.08]:
		sph(b, 0.035, Vector3(x, 1.25, 1.39), Color(0.4, 0.2, 0.2))
	for x in [-1.0, 1.0]:
		sph(b, 0.045, Vector3(x * 0.17, 1.47, 1.18), Color(0.05, 0.05, 0.05))
		cyl(b, 0.02, 0.05, 0.2, Vector3(x * 0.2, 1.68, 0.92), Color(0.95, 0.9, 0.7), 8).rotation_degrees.z = -x * 30.0
		sph(b, 0.1, Vector3(x * 0.34, 1.48, 0.88), Color.WHITE, Vector3(1.4, 0.5, 0.8))
	# legs, udder, tail
	for p in [Vector3(-0.28, 0.35, -0.55), Vector3(0.28, 0.35, -0.55), Vector3(-0.28, 0.35, 0.55), Vector3(0.28, 0.35, 0.55)]:
		cyl(b, 0.1, 0.09, 0.7, p, Color.WHITE, 10)
		cyl(b, 0.1, 0.1, 0.1, p - Vector3(0, 0.33, 0), Color(0.25, 0.2, 0.18), 10)
	sph(b, 0.17, Vector3(0, 0.62, -0.25), pink, Vector3(1.1, 0.8, 1.1))
	cyl(b, 0.02, 0.025, 0.7, Vector3(0, 0.9, -0.85), Color.WHITE, 6).rotation_degrees.x = 15
	sph(b, 0.07, Vector3(0, 0.55, -0.93), black, Vector3(1, 1.5, 1))
	# milk bucket
	skin(cyl(prod, 0.22, 0.18, 0.4, Vector3.ZERO, Color(0.7, 0.7, 0.75), 14), Color(0.7, 0.7, 0.75), 0.8)
	cyl(prod, 0.2, 0.2, 0.05, Vector3(0, 0.2, 0), Color.WHITE, 14)


func build_pig(b: Node3D, prod: Node3D) -> void:
	var pink := Color(0.96, 0.5, 0.58)
	var deep := Color(0.85, 0.35, 0.45)
	sph(b, 0.42, Vector3(0, 0.62, 0), pink, Vector3(1.0, 0.9, 1.35))
	sph(b, 0.3, Vector3(0, 0.75, 0.55), pink)
	cyl(b, 0.13, 0.14, 0.12, Vector3(0, 0.7, 0.86), deep, 14).rotation_degrees.x = 90
	for x in [-0.05, 0.05]:
		sph(b, 0.03, Vector3(x, 0.7, 0.93), Color(0.45, 0.2, 0.25))
	for x in [-1.0, 1.0]:
		sph(b, 0.04, Vector3(x * 0.12, 0.85, 0.8), Color(0.05, 0.05, 0.05))
		var ear := prism(b, Vector3(0.18, 0.18, 0.04), Vector3(x * 0.17, 1.02, 0.55), deep)
		ear.rotation_degrees = Vector3(30, 0, -x * 25.0)
	for p in [Vector3(-0.2, 0.15, -0.3), Vector3(0.2, 0.15, -0.3), Vector3(-0.2, 0.15, 0.3), Vector3(0.2, 0.15, 0.3)]:
		cyl(b, 0.08, 0.07, 0.3, p, pink, 10)
		cyl(b, 0.07, 0.07, 0.05, p - Vector3(0, 0.13, 0), Color(0.45, 0.3, 0.3), 10)
	var tail := TorusMesh.new()
	tail.inner_radius = 0.04
	tail.outer_radius = 0.08
	add_mesh(b, tail, Vector3(0, 0.75, -0.58), deep).rotation_degrees.x = 70
	sph(b, 0.12, Vector3(0.25, 0.85, -0.1), Color(0.55, 0.38, 0.28), Vector3(1.0, 0.3, 1.2))
	# bacon: three wavy rashers
	for k in 3:
		var s := box(prod, Vector3(0.5, 0.05, 0.12), Vector3(0, k * 0.06 - 0.06, (k - 1) * 0.06), Color(0.82, 0.25, 0.22))
		s.rotation_degrees.z = (k - 1) * 12.0
		box(s, Vector3(0.5, 0.055, 0.035), Vector3(0, 0, 0.03), Color(1.0, 0.88, 0.8))


func tap_animal(i: int) -> void:
	var a: Dictionary = animals[i]
	var ad: Dictionary = ANIMALS[a["type"]]
	var n: Node3D = animal_nodes[i]["node"]
	if a["t"] >= ad["t"]:
		a["t"] = 0.0
		add_item(ad["out"], 1)
		gain_xp(1)
		play("pop")
		float_text(n.position, "+1 " + item_name(ad["out"]), Color(1, 1, 0.9))
		animal_nodes[i]["prod"].visible = false
		bounce(animal_nodes[i]["body"])
	else:
		toast("%s ready in %ds" % [item_name(ad["out"]), ceili((ad["t"] - a["t"]) / feed_mult())])
		bounce(animal_nodes[i]["body"])


func buy_animal(type: String) -> void:
	var ad: Dictionary = ANIMALS[type]
	if level < ad["lvl"]:
		toast("%ss unlock at level %d" % [ad["n"], ad["lvl"]])
		play("nope")
		return
	if animal_count(type) >= ad["max"]:
		toast("The pen is full of %ss!" % ad["n"].to_lower())
		play("nope")
		return
	var cost := animal_cost(type)
	if coins < cost:
		toast("Need $%d for a %s" % [cost, ad["n"].to_lower()])
		play("nope")
		return
	coins -= cost
	animals.append({"type": type, "t": 0.0})
	spawn_animal_node(animals.size() - 1)
	play("build")
	float_text(animal_nodes[-1]["node"].position, "New " + ad["n"] + "!", Color(0.6, 1, 0.6))
	refresh_pen_signs()
	refresh_ui()


func refresh_pen_signs() -> void:
	for id in ANIMAL_ORDER:
		var sn: Node3D = get_node("Sign_" + id)
		var l: Label3D = sn.get_meta("label")
		var ad: Dictionary = ANIMALS[id]
		if level < ad["lvl"]:
			l.text = "%ss\nLevel %d" % [ad["n"], ad["lvl"]]
		elif animal_count(id) >= ad["max"]:
			l.text = "%ss\nPen full" % ad["n"]
		else:
			l.text = "Buy %s\n$%d" % [ad["n"], animal_cost(id)]


func update_animals(delta: float) -> void:
	for i in animals.size():
		var a: Dictionary = animals[i]
		var an: Dictionary = animal_nodes[i]
		var n: Node3D = an["node"]
		var ad: Dictionary = ANIMALS[a["type"]]
		var ready: bool = a["t"] >= ad["t"]
		if not ready:
			a["t"] += delta * feed_mult()
		var prod: Node3D = an["prod"]
		prod.visible = ready
		if ready:
			prod.position.y = float(ad["h"]) + sin(clock * 4.0 + i) * 0.12
			prod.rotation.y += delta * 2.0
		an["wait"] -= delta
		if an["wait"] > 0:
			continue
		var tgt: Vector3 = an["target"]
		var to := tgt - n.position
		if to.length() < 0.1:
			an["target"] = Vector3(randf_range(PEN_MIN.x, PEN_MAX.x), 0, randf_range(PEN_MIN.y, PEN_MAX.y))
			an["wait"] = randf_range(1.0, 4.0)
			continue
		var speed: float = ad["spd"]
		n.position += to.normalized() * minf(speed * delta, to.length())
		n.rotation.y = lerp_angle(n.rotation.y, atan2(to.x, to.z), delta * 6.0)
		var body: Node3D = an["body"]
		body.position.y = abs(sin(clock * 10.0 + i)) * 0.06


# ================= cars =================

func available_goods() -> Array:
	var out := []
	for c in CROP_ORDER:
		if level >= CROPS[c]["lvl"]:
			out.append(c)
	for t in ANIMAL_ORDER:
		if animal_count(t) > 0:
			out.append(ANIMALS[t]["out"])
	for s in STATION_ORDER:
		if stations[s]["own"]:
			out.append(STATIONS[s]["out"])
	return out


func spawn_car() -> void:
	var goods := available_goods()
	var weights := []
	var total := 0.0
	for g in goods:
		var w: float = 1.0 + ITEMS[g]["p"] / 10.0
		if have(g) > 0:
			w *= 6.0
		weights.append(w)
		total += w
	var r := randf() * total
	var want: String = goods[0]
	for k in goods.size():
		r -= weights[k]
		if r <= 0:
			want = goods[k]
			break
	var qty := 1 + randi() % mini(4, 1 + int(level / 2.0))
	var pay := int(ceil(ITEMS[want]["p"] * qty * 1.6 * (1.0 + 0.1 * upg["fame"])))
	var n := build_car(CAR_COLORS[randi() % CAR_COLORS.size()])
	n.position = Vector3(-48, 0, LANE_Z)
	var lbl := label3d(n, "", Vector3(0, 2.7, 0), 40)
	add_hit(n, Vector3(3.0, 2.2, 1.8), Vector3(0, 1.0, 0), "car", n.get_instance_id())
	var patience := 45.0 + level * 3.0
	cars.append({"node": n, "want": want, "qty": qty, "pay": pay, "patience": patience, "max": patience, "label": lbl, "leaving": false})


func build_car(c: Color) -> Node3D:
	var n := Node3D.new()
	add_child(n)
	var body := node_at(n, Vector3.ZERO)
	body.name = "Body"
	box(body, Vector3(2.8, 0.55, 1.4), Vector3(0, 0.7, 0), c)
	box(body, Vector3(2.7, 0.2, 1.36), Vector3(0, 0.38, 0), c.darkened(0.25))
	skin(box(body, Vector3(1.5, 0.6, 1.25), Vector3(-0.2, 1.25, 0), c), c, 0.3)
	skin(box(body, Vector3(1.3, 0.42, 1.27), Vector3(-0.2, 1.27, 0), Color(0.55, 0.75, 0.9)), Color(0.55, 0.75, 0.9), 0.6)
	skin(box(body, Vector3(1.53, 0.42, 1.1), Vector3(-0.2, 1.27, 0), Color(0.55, 0.75, 0.9)), Color(0.55, 0.75, 0.9), 0.6)
	box(body, Vector3(0.08, 0.6, 1.27), Vector3(-0.2, 1.25, 0), c)
	for zz in [0.45, -0.45]:
		skin(box(body, Vector3(0.05, 0.16, 0.3), Vector3(1.41, 0.78, zz), Color(1, 1, 0.75)), Color(1, 1, 0.75), 0.0, true)
		skin(box(body, Vector3(0.05, 0.14, 0.25), Vector3(-1.41, 0.78, zz), Color(0.9, 0.1, 0.1)), Color(0.9, 0.1, 0.1), 0.0, true)
	for xx in [1.44, -1.44]:
		skin(box(body, Vector3(0.1, 0.14, 1.44), Vector3(xx, 0.45, 0), Color(0.75, 0.75, 0.78)), Color(0.75, 0.75, 0.78), 0.8)
	for p in [Vector3(0.9, 0.32, 0.7), Vector3(-0.9, 0.32, 0.7), Vector3(0.9, 0.32, -0.7), Vector3(-0.9, 0.32, -0.7)]:
		cyl(body, 0.32, 0.32, 0.25, p, Color(0.12, 0.12, 0.12), 16).rotation_degrees.x = 90
		skin(cyl(body, 0.17, 0.17, 0.27, p, Color(0.8, 0.8, 0.85), 12), Color(0.8, 0.8, 0.85), 0.8).rotation_degrees.x = 90
	return n


func find_car(iid: int) -> int:
	for i in cars.size():
		if cars[i]["node"].get_instance_id() == iid:
			return i
	return -1


func tap_car(iid: int) -> void:
	var i := find_car(iid)
	if i < 0:
		return
	var c: Dictionary = cars[i]
	if c["leaving"]:
		return
	var want: String = c["want"]
	var n: Node3D = c["node"]
	if have(want) < c["qty"]:
		toast("They want %d %s (you have %d)" % [c["qty"], item_name(want), have(want)])
		play("nope")
		bounce(n.get_node("Body"))
		return
	inv[want] = have(want) - c["qty"]
	coins += c["pay"]
	gain_xp(c["pay"])
	play("coin")
	float_text(n.position + Vector3(0, 1, 0), "+$%d" % c["pay"], Color(1, 0.85, 0.2))
	(c["label"] as Label3D).text = "Thanks!"
	(c["label"] as Label3D).modulate = Color(0.6, 1, 0.6)
	c["leaving"] = true
	bounce(n.get_node("Body"))
	refresh_ui()


func update_cars(delta: float) -> void:
	car_timer -= delta
	var waiting := 0
	for c in cars:
		if not c["leaving"]:
			waiting += 1
	if car_timer <= 0:
		if waiting < 3:
			spawn_car()
		car_timer = maxf(3.0, randf_range(8.0, 12.0) - upg["sign"] * 1.4)
	var q := 0
	for i in range(cars.size() - 1, -1, -1):
		var c: Dictionary = cars[i]
		var n: Node3D = c["node"]
		if c["leaving"]:
			n.position.x += delta * 12.0
			if n.position.x > 55:
				n.queue_free()
				cars.remove_at(i)
	for c in cars:
		if c["leaving"]:
			continue
		var n: Node3D = c["node"]
		var target := STAND_X - q * 4.0
		q += 1
		var dist := target - n.position.x
		n.position.x += clampf(dist * 3.0, 0.0, 14.0) * delta
		var lbl: Label3D = c["label"]
		if absf(dist) < 0.5:
			c["patience"] -= delta
			var frac: float = c["patience"] / c["max"]
			lbl.text = "%d %s\n$%d  %ds" % [c["qty"], item_name(c["want"]), c["pay"], ceili(c["patience"])]
			lbl.modulate = Color(1, 1, 1).lerp(Color(1, 0.4, 0.3), 1.0 - frac)
			if c["patience"] <= 0:
				lbl.text = "Too slow!"
				c["leaving"] = true
		else:
			lbl.text = "%d %s\n$%d" % [c["qty"], item_name(c["want"]), c["pay"]]
			lbl.modulate = Color.WHITE
	# ambient traffic on the far lane
	ambient_timer -= delta
	if ambient_timer <= 0:
		ambient_timer = randf_range(4.0, 9.0)
		var a := build_car(CAR_COLORS[randi() % CAR_COLORS.size()])
		a.position = Vector3(55, 0, 12.4)
		a.rotation_degrees.y = 180
		ambient.append(a)
	for i in range(ambient.size() - 1, -1, -1):
		var a: Node3D = ambient[i]
		a.position.x -= delta * 11.0
		if a.position.x < -55:
			a.queue_free()
			ambient.remove_at(i)


# ================= progression =================

func xp_needed() -> int:
	return int(30.0 * pow(level, 1.45))


func gain_xp(n: int) -> void:
	xp += n
	var leveled := false
	while xp >= xp_needed():
		xp -= xp_needed()
		level += 1
		leveled = true
	if leveled:
		var unlocks := []
		for c in CROP_ORDER:
			if CROPS[c]["lvl"] == level:
				unlocks.append(item_name(c) + " seeds")
		for s in STATION_ORDER:
			if STATIONS[s]["lvl"] == level:
				unlocks.append(STATIONS[s]["n"])
		for a in ANIMAL_ORDER:
			if ANIMALS[a]["lvl"] == level:
				unlocks.append(ANIMALS[a]["n"] + "s")
		var msg := "LEVEL %d!" % level
		if unlocks.size() > 0:
			msg += "  Unlocked: " + ", ".join(unlocks)
		toast(msg, 4.0)
		play("level")
		build_seed_bar()
		refresh_pen_signs()
	refresh_ui()


func upgrade_cost(id: String) -> int:
	return int(UPGRADES[id]["cost"] * pow(2.2, upg[id]))


func buy_upgrade(id: String) -> void:
	if upg[id] >= UPGRADES[id]["max"]:
		return
	var cost := upgrade_cost(id)
	if coins < cost:
		toast("Need $%d" % cost)
		play("nope")
		return
	coins -= cost
	upg[id] += 1
	play("build")
	refresh_ui()
	build_upgrade_panel()
	refresh_helpers()


# ================= main loop & input =================

func _process(delta: float) -> void:
	clock += delta
	for i in PLOT_COUNT:
		var p: Dictionary = plots[i]
		if p["crop"] == "":
			continue
		var need: float = CROPS[p["crop"]]["t"]
		p["t"] = minf(p["t"] + delta * grow_mult(), need)
		var crop: Node3D = plot_nodes[i]["crop"]
		if crop == null:
			continue
		var prog: float = p["t"] / need
		if prog >= 1.0:
			crop.scale = Vector3.ONE
			crop.position.y = 0.25 + absf(sin(clock * 4.0 + i)) * 0.15
		else:
			crop.scale = Vector3.ONE * lerpf(0.25, 1.0, prog)
	for id in STATION_ORDER:
		var s: Dictionary = stations[id]
		var spin: Node3D = station_nodes[id]["spin"]
		if s["busy"]:
			s["t"] += delta
			if spin:
				spin.rotation.z += delta * 4.0
			if s["t"] >= STATIONS[id]["t"]:
				s["busy"] = false
				s["ready"] += 1
				if s["ready"] < 5 and station_can_start(id):
					station_start(id)
	update_animals(delta)
	update_cars(delta)
	update_helpers(delta)
	update_helper_bodies(delta)
	ui_timer -= delta
	if ui_timer <= 0:
		ui_timer = 0.25
		for id in STATION_ORDER:
			refresh_station(id)
	save_timer -= delta
	if save_timer <= 0:
		save_timer = 5.0
		save_game()


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		var mb := e as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				pressing = true
				dragging = false
				press_pos = mb.position
			else:
				if pressing and not dragging:
					tap(mb.position)
				pressing = false
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom(-0.08)
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom(0.08)
	elif e is InputEventMouseMotion and pressing:
		var mm := e as InputEventMouseMotion
		if not dragging and press_pos.distance_to(mm.position) > 18.0:
			dragging = true
		if dragging:
			var k := 0.03 * cam_zoom * (800.0 / get_viewport().get_visible_rect().size.y)
			cam_target.x -= mm.relative.x * k
			cam_target.z -= mm.relative.y * k
			cam_target.x = clampf(cam_target.x, -14, 18)
			cam_target.z = clampf(cam_target.z, -10, 8)
			update_camera()
	elif e is InputEventMagnifyGesture:
		zoom((1.0 - (e as InputEventMagnifyGesture).factor))


func zoom(d: float) -> void:
	cam_zoom = clampf(cam_zoom + d, 0.5, 1.5)
	update_camera()


func update_camera() -> void:
	cam.position = cam_target + Vector3(0, 17, 15) * cam_zoom
	cam.look_at(cam_target)


func tap(pos: Vector2) -> void:
	var from := cam.project_ray_origin(pos)
	var q := PhysicsRayQueryParameters3D.create(from, from + cam.project_ray_normal(pos) * 200.0)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return
	var col: Object = hit["collider"]
	if not col.has_meta("kind"):
		return
	var id: Variant = col.get_meta("id")
	match String(col.get_meta("kind")):
		"plot":
			tap_plot(id)
		"station":
			tap_station(id)
		"animal":
			tap_animal(id)
		"buy_animal":
			buy_animal(id)
		"car":
			tap_car(id)


# ================= UI =================

func build_ui() -> void:
	var cl := CanvasLayer.new()
	cl.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(cl)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(root)
	var th := Theme.new()
	th.default_font_size = 24
	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.25, 0.15, 0.08, 0.85)
	panel_sb.set_corner_radius_all(16)
	panel_sb.set_content_margin_all(14)
	panel_sb.border_color = Color(0.95, 0.8, 0.5)
	panel_sb.set_border_width_all(3)
	th.set_stylebox("panel", "PanelContainer", panel_sb)
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = {"normal": Color(0.35, 0.6, 0.25), "hover": Color(0.42, 0.7, 0.3), "pressed": Color(0.25, 0.45, 0.18), "disabled": Color(0.35, 0.35, 0.35), "focus": Color(0, 0, 0, 0)}[st]
		sb.set_corner_radius_all(14)
		sb.set_content_margin_all(12)
		if st == "focus":
			sb.draw_center = false
		th.set_stylebox(st, "Button", sb)
	th.set_color("font_outline_color", "Label", Color.BLACK)
	th.set_constant("outline_size", "Label", 6)
	root.theme = th

	var tl := PanelContainer.new()
	tl.position = Vector2(12, 12)
	tl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tl)
	var v := VBoxContainer.new()
	tl.add_child(v)
	ui_coins = Label.new()
	ui_coins.add_theme_font_size_override("font_size", 38)
	ui_coins.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	v.add_child(ui_coins)
	ui_level = Label.new()
	v.add_child(ui_level)
	ui_xp = ProgressBar.new()
	ui_xp.custom_minimum_size = Vector2(230, 14)
	ui_xp.show_percentage = false
	v.add_child(ui_xp)
	ui_inv = Label.new()
	ui_inv.add_theme_font_size_override("font_size", 21)
	v.add_child(ui_inv)

	var tr := HBoxContainer.new()
	tr.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	tr.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	tr.offset_right = -12
	tr.offset_top = 12
	tr.add_theme_constant_override("separation", 10)
	root.add_child(tr)
	var ub := big_button("Upgrades")
	ub.pressed.connect(func(): build_upgrade_panel(); upg_panel.visible = not upg_panel.visible; help_panel.visible = false)
	tr.add_child(ub)
	var hb := big_button(" ? ")
	hb.pressed.connect(func(): show_help(0))
	tr.add_child(hb)
	var pb := big_button(" II ")
	pb.pressed.connect(set_paused.bind(true))
	tr.add_child(pb)

	var zi := big_button(" + ")
	zi.pressed.connect(func(): zoom(-0.15))
	tr.add_child(zi)
	tr.move_child(zi, 0)
	var zo := big_button(" - ")
	zo.pressed.connect(func(): zoom(0.15))
	tr.add_child(zo)
	tr.move_child(zo, 1)

	seed_box = VBoxContainer.new()
	seed_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	seed_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	seed_box.grow_vertical = Control.GROW_DIRECTION_BOTH
	seed_box.offset_right = -12
	seed_box.add_theme_constant_override("separation", 10)
	root.add_child(seed_box)
	build_seed_bar()

	ui_toast = Label.new()
	ui_toast.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	ui_toast.offset_top = 100
	ui_toast.offset_bottom = 160
	ui_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_toast.add_theme_font_size_override("font_size", 30)
	ui_toast.add_theme_constant_override("outline_size", 10)
	ui_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_toast.modulate.a = 0.0
	root.add_child(ui_toast)

	upg_panel = center_panel(root)
	upg_box = VBoxContainer.new()
	upg_box.add_theme_constant_override("separation", 10)
	upg_panel.add_child(upg_box)
	upg_panel.visible = false

	help_panel = center_panel(root)
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 12)
	help_panel.add_child(hv)
	help_title = Label.new()
	help_title.add_theme_font_size_override("font_size", 36)
	help_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	help_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hv.add_child(help_title)
	help_body = Label.new()
	help_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_body.custom_minimum_size = Vector2(680, 300)
	hv.add_child(help_body)
	help_page_lbl = Label.new()
	help_page_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_page_lbl.add_theme_font_size_override("font_size", 20)
	hv.add_child(help_page_lbl)
	var nav := HBoxContainer.new()
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	nav.add_theme_constant_override("separation", 16)
	hv.add_child(nav)
	help_prev = big_button("  < Back  ")
	help_prev.pressed.connect(func(): show_help(help_page - 1))
	nav.add_child(help_prev)
	help_next = big_button("  Next >  ")
	help_next.pressed.connect(func(): show_help(help_page + 1))
	nav.add_child(help_next)
	var ok := big_button("  Let's farm!  ")
	ok.pressed.connect(close_help)
	nav.add_child(ok)
	help_panel.visible = false

	pause_panel = center_panel(root)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 14)
	pause_panel.add_child(pv)
	var pt := Label.new()
	pt.text = "Paused"
	pt.add_theme_font_size_override("font_size", 44)
	pt.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	pt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(pt)
	var resume := big_button("Resume")
	resume.custom_minimum_size = Vector2(420, 72)
	resume.pressed.connect(set_paused.bind(false))
	pv.add_child(resume)
	var howto := big_button("How to Play")
	howto.pressed.connect(func(): pause_panel.visible = false; show_help(0))
	pv.add_child(howto)
	mute_btn = big_button("")
	mute_btn.pressed.connect(func(): muted = not muted; apply_mute(); save_game())
	pv.add_child(mute_btn)
	reset_btn = big_button("Start New Farm")
	reset_btn.pressed.connect(reset_pressed)
	pv.add_child(reset_btn)
	pause_panel.visible = false
	apply_mute()


func help_pages() -> Array:
	var recipes := []
	for id in STATION_ORDER:
		var st: Dictionary = STATIONS[id]
		recipes.append("- %s (Lv %d): %s makes %s" % [st["n"], st["lvl"], recipe_text(st["in"]), item_name(st["out"])])
	return [
		["Welcome to Barry's Barn!", "Barry's farm stand sits next to a busy road. Grow crops, raise animals, cook tasty goods and sell them to the cars that stop by.\n\nEarn money to buy more plots, animals, stations and helpers. Selling also earns XP, and every new level unlocks something new.\n\nTap Next for a quick tour. You can open this again with the ? button."],
		["Crops", "1. Pick a seed on the right side of the screen.\n2. Tap a brown dirt plot to plant it.\n3. When the crop starts bouncing it is ready: tap it to harvest 2.\n\nHarvested plots replant the same seed by themselves. Green plots are locked: tap the one marked \"Buy Plot\" to expand your field.\n\nWheat seeds are free, so you can never get stuck."],
		["Animals", "Chickens lay eggs, cows give milk (level 3) and pigs give bacon (level 5).\n\nWhen an egg, milk bucket or bacon floats above an animal, tap the animal to collect it.\n\nBuy more animals from the signs in front of the pen."],
		["Kitchen Stations", "Stations turn raw items into goods that sell for much more. Tap an empty pad to build one, then tap it to start cooking. It keeps cooking by itself while you have ingredients. Tap it when it says READY to collect.\n\n" + "\n".join(recipes)],
		["Selling", "Cars line up at the farm stand. Each shows what it wants, the price, and how long it will wait.\n\nTap a car to sell. If you don't have what it wants, keep farming: it will wait a while, and new cars ask for things you already have more often."],
		["Helpers (automation)", "Tired of tapping? Hire helpers in the Upgrades menu. They show up on the farm and keep working while you play:\n\n- Scarecrow Farmhand: harvests ripe crops\n- Barn Robot: collects eggs, milk and bacon\n- Kitchen Helper: collects and restarts stations\n- Stand Clerk: sells to cars when you have their order\n\nEach helper can be upgraded twice to work faster. With all four, your farm runs itself."],
		["Controls & Tips", "- Tap: plant, harvest, collect, build, sell\n- Drag: move the camera\n- + / - buttons (or mouse wheel / pinch): zoom\n- II button: pause, sound, restart\n\nTips: build the Mill early, since flour sells for nearly 4x wheat. Hire the Stand Clerk first so cars never leave unhappy. The game saves by itself."],
	]


func show_help(page: int) -> void:
	var pages := help_pages()
	help_page = clampi(page, 0, pages.size() - 1)
	help_title.text = pages[help_page][0]
	help_body.text = pages[help_page][1]
	help_page_lbl.text = "Page %d of %d" % [help_page + 1, pages.size()]
	help_prev.disabled = help_page == 0
	help_next.disabled = help_page == pages.size() - 1
	upg_panel.visible = false
	help_panel.visible = true
	get_tree().paused = true


func close_help() -> void:
	help_panel.visible = false
	get_tree().paused = false
	if not seen_help:
		seen_help = true
		save_game()


func set_paused(p: bool) -> void:
	get_tree().paused = p
	pause_panel.visible = p
	upg_panel.visible = false
	help_panel.visible = false
	reset_btn.text = "Start New Farm"


func apply_mute() -> void:
	AudioServer.set_bus_mute(0, muted)
	mute_btn.text = "Sound: OFF" if muted else "Sound: ON"


func reset_pressed() -> void:
	if reset_btn.text != "Tap again to erase your farm!":
		reset_btn.text = "Tap again to erase your farm!"
		return
	resetting = true
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().paused = false
	get_tree().reload_current_scene()


func update_helpers(delta: float) -> void:
	for h in HELPERS:
		var lv: int = upg[h]
		if lv == 0:
			continue
		helper_timers[h] = float(helper_timers.get(h, 0.0)) - delta
		if helper_timers[h] > 0.0:
			continue
		helper_timers[h] = HELPER_INTERVAL[lv]
		match h:
			"farmhand":
				for i in PLOT_COUNT:
					var p: Dictionary = plots[i]
					if p["open"] and p["crop"] != "" and p["t"] >= CROPS[p["crop"]]["t"]:
						tap_plot(i)
						send_helper(h, plot_pos(i) + Vector3(0, 0, 1.3))
						break
			"collector":
				for i in animals.size():
					if animals[i]["t"] >= ANIMALS[animals[i]["type"]]["t"]:
						tap_animal(i)
						send_helper(h, animal_nodes[i]["node"].position + Vector3(0, 0, 0.9))
						break
			"chef":
				for id in STATION_ORDER:
					var s: Dictionary = stations[id]
					if s["own"] and (s["ready"] > 0 or (not s["busy"] and station_can_start(id))):
						tap_station(id)
						send_helper(h, station_pos(STATION_ORDER.find(id)) + Vector3(0, 0, 1.9))
						break
			"seller":
				for c in cars:
					var n: Node3D = c["node"]
					if not c["leaving"] and absf(n.position.x - STAND_X) < 13.0 and have(c["want"]) >= c["qty"]:
						tap_car(n.get_instance_id())
						send_helper(h, Vector3(clampf(n.position.x, STAND_X - 1.5, STAND_X + 1.5), 0, 6.5))
						break


# ================= helper bodies =================

func helper_home(h: String) -> Vector3:
	match h:
		"farmhand":
			return Vector3(-16.6, 0, -1.0)
		"collector":
			return Vector3(8.4, 0, -8.8)
		"chef":
			return Vector3(-5.2, 0, 4.8)
	return Vector3(STAND_X + 0.6, 0, 6.5)


## Spawns a visible body for every hired helper that doesn't have one yet.
func refresh_helpers() -> void:
	for h in HELPERS:
		if upg[h] == 0 or helper_nodes.has(h):
			continue
		var n := node_at(self, helper_home(h))
		var body := node_at(n, Vector3.ZERO)
		match h:
			"farmhand":
				build_scarecrow(body)
			"collector":
				build_robot(body, Color(0.45, 0.65, 0.85), Color(0.3, 1.0, 0.6), "basket")
			"chef":
				build_robot(body, Color(0.92, 0.92, 0.95), Color(1.0, 0.7, 0.2), "chef")
			"seller":
				build_robot(body, Color(0.95, 0.75, 0.25), Color(0.3, 0.8, 1.0), "cap")
		n.rotation.y = PI if h == "collector" else 0.0
		helper_nodes[h] = {"node": n, "body": body, "target": n.position}


func build_scarecrow(b: Node3D) -> void:
	var straw := Color(0.95, 0.82, 0.4)
	cyl(b, 0.06, 0.07, 1.6, Vector3(0, 0.8, 0), WOOD, 8)
	box(b, Vector3(1.6, 0.08, 0.08), Vector3(0, 1.45, 0), WOOD)
	box(b, Vector3(0.6, 0.65, 0.34), Vector3(0, 1.35, 0), Color(0.75, 0.2, 0.2))
	for k in 3:
		box(b, Vector3(0.62, 0.04, 0.36), Vector3(0, 1.15 + k * 0.2, 0), Color(0.45, 0.1, 0.1))
	box(b, Vector3(0.62, 0.3, 0.36), Vector3(0, 0.95, 0), Color(0.3, 0.4, 0.7))
	for x in [-0.6, 0.6]:
		box(b, Vector3(0.45, 0.2, 0.22), Vector3(x, 1.45, 0), Color(0.75, 0.2, 0.2))
		cyl(b, 0.0, 0.08, 0.22, Vector3(x * 1.42, 1.45, 0), straw, 6).rotation_degrees.z = 90.0 * signf(x)
	sph(b, 0.26, Vector3(0, 1.92, 0), Color(0.85, 0.72, 0.5))
	for x in [-0.09, 0.09]:
		sph(b, 0.04, Vector3(x, 1.97, 0.23), Color(0.1, 0.1, 0.1))
	box(b, Vector3(0.16, 0.03, 0.02), Vector3(0, 1.82, 0.25), Color(0.1, 0.1, 0.1))
	cyl(b, 0.5, 0.5, 0.04, Vector3(0, 2.1, 0), straw, 16)
	cyl(b, 0.18, 0.24, 0.26, Vector3(0, 2.24, 0), straw, 12)
	cyl(b, 0.235, 0.235, 0.06, Vector3(0, 2.15, 0), Color(0.75, 0.2, 0.2), 12)


## A friendly round robot on a wheel. hat: "basket", "chef" or "cap".
func build_robot(b: Node3D, c: Color, eye: Color, hat: String) -> void:
	var steel := Color(0.6, 0.62, 0.66)
	var dark := Color(0.15, 0.16, 0.2)
	skin(cyl(b, 0.22, 0.22, 0.18, Vector3(0, 0.22, 0), dark, 16), dark, 0.3).rotation_degrees.z = 90
	skin(cyl(b, 0.08, 0.08, 0.22, Vector3(0, 0.22, 0), steel, 10), steel, 0.8).rotation_degrees.z = 90
	skin(cyl(b, 0.12, 0.2, 0.3, Vector3(0, 0.5, 0), steel, 12), steel, 0.8)
	skin(sph(b, 0.42, Vector3(0, 0.95, 0), c, Vector3(1, 0.95, 0.9)), c, 0.5)
	skin(cyl(b, 0.3, 0.3, 0.02, Vector3(0, 0.95, 0.36), dark, 16), dark, 0.2).rotation_degrees.x = 90
	skin(box(b, Vector3(0.22, 0.12, 0.04), Vector3(0, 0.98, 0.38), eye), eye, 0.0, true)
	skin(sph(b, 0.06, Vector3(-0.07, 1.08, 0.37), eye), eye, 0.0, true)
	# head
	skin(cyl(b, 0.08, 0.1, 0.12, Vector3(0, 1.4, 0), steel, 10), steel, 0.8)
	skin(box(b, Vector3(0.62, 0.42, 0.48), Vector3(0, 1.66, 0), c), c, 0.5)
	skin(box(b, Vector3(0.5, 0.24, 0.04), Vector3(0, 1.68, 0.25), dark), dark, 0.2)
	for x in [-0.12, 0.12]:
		skin(sph(b, 0.065, Vector3(x, 1.68, 0.27), eye), eye, 0.0, true)
	for x in [-0.33, 0.33]:
		skin(cyl(b, 0.09, 0.09, 0.06, Vector3(x, 1.66, 0), steel, 12), steel, 0.8).rotation_degrees.z = 90
	# arms
	for x in [-1.0, 1.0]:
		var arm := node_at(b, Vector3(x * 0.42, 1.05, 0))
		arm.name = "ArmL" if x < 0 else "ArmR"
		skin(sph(arm, 0.1, Vector3.ZERO, steel), steel, 0.8)
		skin(cyl(arm, 0.05, 0.05, 0.4, Vector3(x * 0.05, -0.22, 0.05), steel, 8), steel, 0.8)
		skin(sph(arm, 0.09, Vector3(x * 0.06, -0.45, 0.08), c), c, 0.5)
	match hat:
		"basket":
			skin(cyl(b, 0.012, 0.012, 0.3, Vector3(0, 2.02, 0), steel, 6), steel, 0.8)
			skin(sph(b, 0.07, Vector3(0, 2.2, 0), eye), eye, 0.0, true)
			cyl(b, 0.3, 0.24, 0.25, Vector3(0, 0.85, -0.42), WOOD, 12)
			sph(b, 0.08, Vector3(-0.08, 0.98, -0.42), Color(1, 0.96, 0.88), Vector3(1, 1.3, 1))
			sph(b, 0.08, Vector3(0.08, 0.98, -0.38), Color(1, 0.96, 0.88), Vector3(1, 1.3, 1))
		"chef":
			cyl(b, 0.26, 0.24, 0.2, Vector3(0, 1.97, 0), Color.WHITE, 14)
			sph(b, 0.3, Vector3(0, 2.15, 0), Color.WHITE, Vector3(1, 0.7, 1))
			box(b, Vector3(0.5, 0.5, 0.05), Vector3(0, 0.85, 0.4), Color(0.95, 0.4, 0.35))
		"cap":
			cyl(b, 0.3, 0.3, 0.14, Vector3(0, 1.94, 0), Color(0.85, 0.2, 0.2), 14)
			box(b, Vector3(0.4, 0.04, 0.25), Vector3(0, 1.88, 0.3), Color(0.85, 0.2, 0.2))
			box(b, Vector3(0.5, 0.55, 0.05), Vector3(0, 0.85, 0.4), Color(0.3, 0.55, 0.3))


## Points a helper at the spot it just worked on.
func send_helper(h: String, spot: Vector3) -> void:
	if helper_nodes.has(h):
		helper_nodes[h]["target"] = spot
		bounce(helper_nodes[h]["body"])


func update_helper_bodies(delta: float) -> void:
	for h in helper_nodes:
		var hn: Dictionary = helper_nodes[h]
		var n: Node3D = hn["node"]
		var body: Node3D = hn["body"]
		var to: Vector3 = hn["target"] - n.position
		to.y = 0
		var moving := to.length() > 0.1
		if moving:
			n.position += to.normalized() * minf(4.5 * delta, to.length())
			n.rotation.y = lerp_angle(n.rotation.y, atan2(to.x, to.z), delta * 8.0)
		body.position.y = (absf(sin(clock * 12.0)) * 0.08 if moving else sin(clock * 2.0) * 0.04)
		if h == "farmhand":
			body.rotation.z = sin(clock * 10.0) * 0.12 if moving else 0.0
			continue
		var swing := sin(clock * (10.0 if moving else 2.0)) * (0.6 if moving else 0.15)
		(body.get_node("ArmL") as Node3D).rotation.x = swing
		(body.get_node("ArmR") as Node3D).rotation.x = -swing


func big_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(64, 64)
	b.focus_mode = Control.FOCUS_NONE
	return b


func center_panel(root: Control) -> PanelContainer:
	var p := PanelContainer.new()
	p.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.add_child(p)
	return p


func build_seed_bar() -> void:
	if seed_box == null:
		return
	for c in seed_box.get_children():
		c.queue_free()
	for id in CROP_ORDER:
		var cd: Dictionary = CROPS[id]
		var b := big_button("")
		b.custom_minimum_size = Vector2(150, 72)
		if level < cd["lvl"]:
			b.text = "%s\nLv %d" % [item_name(id), cd["lvl"]]
			b.disabled = true
		else:
			var price := "free" if cd["seed"] == 0 else "$%d" % cd["seed"]
			b.text = "%s\n%s" % [item_name(id), price]
			if id == sel_crop:
				var sb := StyleBoxFlat.new()
				sb.bg_color = Color(0.95, 0.7, 0.2)
				sb.set_corner_radius_all(14)
				sb.set_content_margin_all(12)
				sb.border_color = Color.WHITE
				sb.set_border_width_all(4)
				b.add_theme_stylebox_override("normal", sb)
				b.add_theme_stylebox_override("hover", sb)
			b.pressed.connect(func(): sel_crop = id; build_seed_bar(); play("pop"))
		seed_box.add_child(b)


func build_upgrade_panel() -> void:
	for c in upg_box.get_children():
		c.queue_free()
	var t := Label.new()
	t.text = "Upgrades"
	t.add_theme_font_size_override("font_size", 34)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upg_box.add_child(t)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	upg_box.add_child(grid)
	for id in UPGRADE_ORDER:
		var u: Dictionary = UPGRADES[id]
		var b := big_button("")
		b.custom_minimum_size = Vector2(440, 76)
		b.add_theme_font_size_override("font_size", 20)
		if upg[id] >= u["max"]:
			b.text = "%s (MAX)\n%s" % [u["n"], u["d"]]
			b.disabled = true
		else:
			b.text = "%s  Lv %d  -  $%d\n%s" % [u["n"], upg[id] + 1, upgrade_cost(id), u["d"]]
			b.pressed.connect(func(): buy_upgrade(id))
		grid.add_child(b)
	var close := big_button("Close")
	close.pressed.connect(func(): upg_panel.visible = false)
	upg_box.add_child(close)


func refresh_ui() -> void:
	if ui_coins == null:
		return
	ui_coins.text = "$%d" % coins
	ui_level.text = "Level %d" % level
	ui_xp.max_value = xp_needed()
	ui_xp.value = xp
	var lines := []
	for id in ITEM_ORDER:
		if have(id) > 0:
			lines.append("%s  x%d" % [item_name(id), have(id)])
	ui_inv.text = "\n".join(lines) if lines.size() > 0 else "(basket empty)"
	refresh_pen_signs()
	var nl := next_locked()
	if nl >= 0:
		(plot_nodes[nl]["label"] as Label3D).text = "Buy Plot\n$%d" % plot_cost()


func toast(msg: String, dur := 2.0) -> void:
	ui_toast.text = msg
	ui_toast.modulate.a = 1.0
	if toast_tween:
		toast_tween.kill()
	toast_tween = create_tween()
	toast_tween.tween_interval(dur)
	toast_tween.tween_property(ui_toast, "modulate:a", 0.0, 0.5)


# ================= save / load =================

func save_game() -> void:
	if resetting:
		return
	var d := {"coins": coins, "xp": xp, "level": level, "inv": inv, "plots": plots, "stations": stations,
		"animals": animals, "upg": upg, "sel": sel_crop, "help": seen_help, "muted": muted}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(d) != TYPE_DICTIONARY:
		return
	coins = int(d.get("coins", coins))
	xp = int(d.get("xp", 0))
	level = int(d.get("level", 1))
	sel_crop = str(d.get("sel", "wheat"))
	seen_help = bool(d.get("help", false))
	inv = {}
	for k in d.get("inv", {}):
		inv[k] = int(d["inv"][k])
	var ps: Array = d.get("plots", [])
	for i in mini(ps.size(), PLOT_COUNT):
		plots[i] = {"open": bool(ps[i]["open"]), "crop": str(ps[i]["crop"]), "t": float(ps[i]["t"])}
	var ss: Dictionary = d.get("stations", {})
	for id in ss:
		if stations.has(id):
			stations[id] = {"own": bool(ss[id]["own"]), "busy": bool(ss[id]["busy"]), "t": float(ss[id]["t"]), "ready": int(ss[id]["ready"])}
	animals = []
	for a in d.get("animals", []):
		animals.append({"type": str(a["type"]), "t": float(a["t"])})
	muted = bool(d.get("muted", false))
	var u: Dictionary = d.get("upg", {})
	for k in u:
		if upg.has(k):
			upg[k] = int(u[k])


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_game()
