# FlagWanderer.gd
extends Node

const MOVE_SPEED := 28.0
const ARRIVE_THRESHOLD := 4.0
const WANDER_INTERVAL_MIN := 0.4
const WANDER_INTERVAL_MAX := 1.4
const POLYGON_INSET := 6.0
const MIN_WALK_DISTANCE := 18.0

var _chibi: Node2D = null
var _sprite: AnimatedSprite2D = null
var _nav_region: NavigationRegion2D = null

var _is_moving := false
var _bob_tween: Tween = null
var _move_tween: Tween = null
var _waiting := false
var _last_direction := Vector2.DOWN

func setup(chibi: Node2D, sprite: AnimatedSprite2D, nav_region: NavigationRegion2D) -> void:
	_chibi = chibi
	_sprite = sprite
	_nav_region = nav_region

	_sprite.position.y = 0.0
	_sprite.play("Front")
	_schedule_next_wander()

func _inset_polygon(outline: PackedVector2Array, amount: float) -> PackedVector2Array:
	var count = outline.size()
	var result := PackedVector2Array()
	for i in range(count):
		var prev = outline[(i - 1 + count) % count]
		var curr = outline[i]
		var next = outline[(i + 1) % count]
		var edge_a = (curr - prev).normalized()
		var edge_b = (next - curr).normalized()
		var normal_a = Vector2(-edge_a.y, edge_a.x)
		var normal_b = Vector2(-edge_b.y, edge_b.x)
		var bisector = (normal_a + normal_b).normalized()
		result.append(curr + bisector * amount)
	return result

func _pick_random_nav_point() -> Vector2:
	var region_transform = _nav_region.global_transform
	var poly = _nav_region.navigation_polygon
	if not poly or poly.get_outline_count() == 0:
		return _chibi.global_position

	var outline = poly.get_outline(0)
	var inset = _inset_polygon(outline, POLYGON_INSET)

	var min_p = inset[0]
	var max_p = inset[0]
	for p in inset:
		min_p = min_p.min(p)
		max_p = max_p.max(p)

	# Try to find a point that is inside the inset polygon AND far enough away
	for _i in range(60):
		var candidate = Vector2(
			randf_range(min_p.x, max_p.x),
			randf_range(min_p.y, max_p.y)
		)
		if not _point_in_polygon(candidate, inset):
			continue
		var world_candidate = region_transform * candidate
		if _chibi.global_position.distance_to(world_candidate) >= MIN_WALK_DISTANCE:
			return world_candidate

	# Fallback: pick the inset vertex farthest from current position
	var best = region_transform * inset[0]
	var best_dist := _chibi.global_position.distance_to(best)
	for p in inset:
		var wp = region_transform * p
		var d = _chibi.global_position.distance_to(wp)
		if d > best_dist:
			best_dist = d
			best = wp
	return best

func _point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	var inside := false
	var j := polygon.size() - 1
	for i in range(polygon.size()):
		var xi = polygon[i].x
		var yi = polygon[i].y
		var xj = polygon[j].x
		var yj = polygon[j].y
		if ((yi > point.y) != (yj > point.y)) and \
				(point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi):
			inside = not inside
		j = i
	return inside

func _schedule_next_wander() -> void:
	if _waiting:
		return
	_waiting = true
	var delay = randf_range(WANDER_INTERVAL_MIN, WANDER_INTERVAL_MAX)
	await get_tree().create_timer(delay).timeout
	_waiting = false
	if not is_instance_valid(_chibi):
		return
	_start_wander()

func _start_wander() -> void:
	var target = _pick_random_nav_point()
	var direction = (target - _chibi.global_position).normalized()
	var distance = _chibi.global_position.distance_to(target)
	var duration = distance / MOVE_SPEED

	_is_moving = true
	_last_direction = direction
	_update_animation(direction)

	if _move_tween:
		_move_tween.kill()
	_move_tween = _chibi.create_tween()
	_move_tween.tween_property(_chibi, "global_position", target, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	_move_tween.finished.connect(_arrive, CONNECT_ONE_SHOT)

	_sprite.position.y = 0.0
	_start_bob()

func _arrive() -> void:
	_is_moving = false
	if not is_instance_valid(_sprite):
		return
	_stop_bob()
	_sprite.position.y = 0.0
	_update_animation(_last_direction)
	_schedule_next_wander()

func _update_animation(direction: Vector2) -> void:
	if not is_instance_valid(_sprite):
		return
	var iso_dir = direction.rotated(deg_to_rad(-45))
	var anim_name: String
	var flip_h := false

	if abs(iso_dir.x) > abs(iso_dir.y):
		anim_name = "Front"
		flip_h = iso_dir.x > 0
	else:
		anim_name = "Front" if iso_dir.y > 0 else "Back"

	_sprite.flip_h = not flip_h
	if _sprite.animation != anim_name:
		_sprite.play(anim_name)

func _start_bob() -> void:
	if not is_instance_valid(_sprite):
		return
	_stop_bob()
	var base_y = _sprite.position.y
	_bob_tween = _sprite.create_tween()
	_bob_tween.set_loops()
	_bob_tween.tween_property(_sprite, "position:y", base_y + 6, 0.15) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
	_bob_tween.tween_property(_sprite, "position:y", base_y, 0.25) \
		.set_trans(Tween.TRANS_SPRING) \
		.set_ease(Tween.EASE_OUT)

func _stop_bob() -> void:
	if _bob_tween:
		_bob_tween.kill()
		_bob_tween = null
