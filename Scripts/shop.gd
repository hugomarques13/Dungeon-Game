extends Control

@onready var Units = $Units
@onready var Traps = $Traps
@onready var Fields = $Fields
@onready var TabName = $TabName
@onready var VContainer = $ScrollContainer/VBoxContainer
@onready var Template = $ScrollContainer/VBoxContainer/Template
@onready var SidePanel = $SidePanel
@onready var Player = $"../../Player"
@onready var TopBar = $"../TopBar"
@onready var UnitsHudContainer = $"../TopBar/UnitsContainer/HBoxContainer"
@onready var UnitsHudTemplate = $"../TopBar/UnitsContainer/HBoxContainer/Template"
@onready var TrapsHudContainer = $"../TopBar/TrapsContainer/HBoxContainer"
@onready var TrapsHudTemplate = $"../TopBar/TrapsContainer/HBoxContainer/Template"
@onready var FieldsHudContainer = $"../TopBar/FieldsContainer/HBoxContainer"
@onready var FieldsHudTemplate = $"../TopBar/FieldsContainer/HBoxContainer/Template"
@onready var ChibiPlace = $"../../ChibiPlace"
@onready var CombatManager = $"../../Combat"
@onready var EnemyManager = $"../../Chibis"
@onready var FloorHandler = $"../FloorUI"
@onready var DungeonOpener = $"../DungeonOpener"
@onready var DialogueManager = $"../../DialogueLayer/Dialogue"

var FieldPlaceSound = preload("res://Sounds/FieldPlace.wav")
var TrapPlaceSound = preload("res://Sounds/TrapPlace1.wav")

const FLAG_DROP_RANGE = 90

const baseIcons = {
	"Units" = preload("res://Sprites/HUD/Shop/IconUnits.png"),
	"Traps" = preload("res://Sprites/HUD/Shop/IconTraps.png"),
	"Fields" = preload("res://Sprites/HUD/Shop/IconFields.png")
}

const activeIcons = {
	"Units" = preload("res://Sprites/HUD/Shop/IconUnits2.png"),
	"Traps" = preload("res://Sprites/HUD/Shop/IconTraps2.png"),
	"Fields" = preload("res://Sprites/HUD/Shop/IconFields2.png")
}

const iconTitles = {
	"Units" = "Wicked Contracts",
	"Traps" = "Architectural Hazards",
	"Fields" = "Ritualism Handiwork"
}

var units = {
	"Lesser Zombie" = {
		LoreDescription = "\"Cheap souls long cast aside, taken in by neither Heaven nor Hell. Lowest of the low. Thus perfect for our uses.\"",
		SkillsDescription = "It's starving, decaying form is more than willing to pathetically chomp down on anything that crosses its path.",
		Cost = 20,
		UnlockCost = 2
	},
	"Greater Zombie" = {
		LoreDescription = "\"We took a zombie... And added another zombie. Positive meets negative. Ingenius of you to come up with that Grand Majesty. You're so right!\"",
		SkillsDescription = "This conjoined abomination can use its extra arms to hit a foe twice.",
		Cost = 25,
		UnlockCost = 50
	},
	"Skeleton" = {
		LoreDescription = "\"As lowly as creatures as the Zombies, however their bare form makes for excellent vessels for the Dark Arts.\"",
		SkillsDescription = "A lesser creature like the ones before it, but its past experiences living human life as a warrior allows it to deliver the occasional decisive blow.",
		Cost = 25,
		UnlockCost = 50
	},
	"Grave Thief" = {
		LoreDescription = "\"A mind-controlled mortal for your bidding, Grand Majesty. Well, they actually submitted himself willingly. Was tired of work, he said.\"",
		SkillsDescription = "It's cowardly strikes allows it to tap into the realm of the dead.  When killing an enemy with its Skill, grants bonus Souls. Otherwise quite unremarkable.",
		Cost = 25,
		UnlockCost = 50
	},
	"Undead Archers" = {
		LoreDescription = "\"These ladies always hit their mark, and have had hundreds of years of target practice.. Hmmm I wonder if they're free after the Dungeon Raids...\"",
		SkillsDescription = "Able to unleash a barrage of arrows upon a foe, and additionally Mark a target of their choice, which will receive bonus damage when hit.",
		Cost = 100,
		UnlockCost = 250
	},
	"Necromancer" = {
		LoreDescription = "\"A tainted practitioner of the Dark Arts who specializes in raising the dead. Essential for any dark civilization looking to up their numbers.\"",
		SkillsDescription = "Call upon the dead and summon forth Skeletons as allies, provided there's room in the party.\nAdditionaly, can wield the bones of the deceased to hit a group of foes.",
		Cost = 100,
		UnlockCost = 250
	},
	"Haunted Knight" = {
		LoreDescription = "\"Old Warriors who couldn't let go of the ways of combat, brought back for your amusement. All they do is fight. Not very personable...\"",
		SkillsDescription = "This haunting servant of the past is able to wield it's claymore with great proficiency, Cutting down entire groups in one fell swoop.\nAdditionally, its training with the blade allow it to ready itself to reflect blows from enemies.",
		Cost = 100,
		UnlockCost = 250
	},
	"Vexing Fool" = {
		LoreDescription = "\"An ancient creat....\nI hate this one. I can't stand her. Get her out of here. So unserious. Grand Majesty Sir look at her! She's playing with my dentures again!\"",
		SkillsDescription = "Quick on her jester feet and particularly disruptive. So disruptive in fact— with her skills, she can dance around attacks with ease, while flaunting herself as a taunt to her enemies. Excellent to keep the heat off of the others.\nShe is passively 10% more likely to dodge enemy attacks.",
		Cost = 500,
		UnlockCost = 2000
	},
	"Infant Dragon" = {
		LoreDescription = "\"Just a little hatchling. Still a greater lifeform than most, even this early into it's life. Very much tamper prone... Handle with care.\"",
		SkillsDescription = "A little menace straight off the womb— It wields its embers dangerously. Breathe out a weaker burst of fire, or one yet stronger, which doesn't discriminate allie from foe.\nIt may even sacrifice itself in a burst of fiery hunger and try to take the enemy with itself.",
		Cost = 500,
		UnlockCost = 2000
	},
	"Malice Wizard" = {
		LoreDescription = "\"Deranged, charred and disfigured practitioners of the Dark Arts only kept alive by the very force they dabble in. Their ways of undress are quite uncouth, Sir.\"",
		SkillsDescription = "And his tune was electric— A deranged monster specializing in destructive magic. Cast out erratic streaks of lightning that arc between foes, or an orb made of raw malice. A Malice Wizard can also choose to sacrifice a portion of it's life force to temporarily strengthen itself.",
		Cost = 500,
		UnlockCost = 2000
	},
	"Full Dragon" = {
		LoreDescription = "\"Now we're talking. An absolutely monstrosity of nature, born through adequate breeding and extended rituals. Enough to put a kingdom on it's knees.\"",
		SkillsDescription = "Char them with the flames of infamy. Chomp their heads off with fangs fit for true hunger .Swipe them aside with descending force. All are lowly compared to the greatest form of monster there is.\nImmune to Burn.",
		Cost = 2500,
		UnlockCost = 5000,
		VisualOffset = -30
	},
	"Truestill Reaper" = {
		LoreDescription = "\"The univeral Truth.\"",
		SkillsDescription = "The hand from the other side...\nOnce— A bountiful harvest, three times its abundance...\nTwice— A fervent release, of every Soul within...\nThrice— A silent beat, of every hex and fear...\n...Death cannot be decided for Him.",
		Cost = 999999999,
		UnlockCost = 5000,
		VisualOffset = -150
	},
}

const traps = {
	"Piercing Spike" = {
		LoreDescription = "\"A classic. Discreet and sleek design that pops in and out to impale unsuspecting adventurers.\"",
		SkillsDescription = "Deals low damage and inflicts Bleed for 2 turns on all enemies.",
		Cost = 250,
		UnlockCost = 500,
		Scene = preload("res://Prefabs/Traps/Spikes.tscn"),
		Icon = preload("res://Prefabs/Icons/Spikes.tscn")
	},
	"Fire Geyser" = {
		LoreDescription = "\"In a move that breaks several mortal laws, we make good use of our underground Dragon breeding grounds and channel their breaths right at the invaders. Not like Dragon Hatchlings have anything better to do.\"",
		SkillsDescription = "Releases a burst of fire that inflicts 3 Burn to all enemies.",
		Cost = 250,
		UnlockCost = 500,
		Scene = preload("res://Prefabs/Traps/Fire.tscn"),
		Icon = preload("res://Prefabs/Icons/Fire.tscn")
	},
	"Acidic Path" = {
		LoreDescription = "\"A deceptively corrosive pool of acid made out of bile. They'll HAVE to cross this. It's just human nature. No other way around it. They're not ninjas, you know.\"",
		SkillsDescription = "Inflicts 2 Weaken on all enemies.",
		Cost = 250,
		UnlockCost = 500,
		Scene = preload("res://Prefabs/Traps/Acid.tscn"),
		Icon = preload("res://Prefabs/Icons/Acid.tscn")
	},
	"Crystal Burst" = {
		LoreDescription = "\"These powerful crystals foraged by our Malice Wizards drain any light that would enter our Dungeon— and then converts them into a snare that can target and incapacitate a foe for a period of time.. If mortals cherish their precious sunlight so much, they'll enjoy this one.\"",
		SkillsDescription = "Stuns 1 random enemy.",
		Cost = 1000,
		UnlockCost = 2000,
		Scene = preload("res://Prefabs/Traps/Stun.tscn"),
		Icon = preload("res://Prefabs/Icons/Stun.tscn")
	},
}

const fields = {
	"Impair Field" = {
		LoreDescription = "\"The symbols carved onto these tiles by our Ritualists bring forth unpleasant reminders about the present and the future, flooding the minds of those present and inducing them with anxiety and confusion. As for why our troops are unaffected? Oh, they have no reason to care or worry, nor anything to lose. Sacrificing it all has its perks after all.\"",
		SkillsDescription = "+1 Cooldown to All Enemies.",
		Cost = 250,
		UnlockCost = 500,
		Scene = preload("res://Prefabs/Fields/Impair.tscn"),
		Icon = preload("res://Prefabs/Icons/Impair.tscn")
	},
	"Haste Field" = {
		LoreDescription = "\"These magical tiles sculpted by our Ritualists stimulates our soldiery by projecting illusory visions of their best days into their surroundings, leading to an enhanced performance in battle. Me? I don't think that's cruek. It's a reminder they're here for a reason and deserve to suffer.\"",
		SkillsDescription = "-1 Cooldown to All Units.",
		Cost = 350,
		UnlockCost = 750,
		Scene = preload("res://Prefabs/Fields/Haste.tscn"),
		Icon = preload("res://Prefabs/Icons/Haste.tscn")
	},
}

var ally_characters = {}

var current_button = null

var currently_dragging = null

var placement_preview: Polygon2D = null
var last_mouse_pos = Vector2.ZERO
var cached_nearest_tile = null
var top_bar_visibility = false

var field_placement_preview: Polygon2D = null
var last_mouse_pos_field = Vector2.ZERO
var cached_nearest_flag_tile = null

var has_given_dialogue = false

func _ready():
	load_unit_assets()
	pressed_icon(Units)
	CombatManager.load_assets("res://Prefabs/Allies/", ally_characters)
	
func _process(delta):
	if currently_dragging:
		currently_dragging.position = get_global_mouse_position()
		update_trap_preview()
		update_field_preview()

func _on_units_pressed() -> void:
	pressed_icon(Units)

func _on_traps_pressed() -> void:
	pressed_icon(Traps)

func _on_fields_pressed() -> void:
	pressed_icon(Fields)

func reset_icon(button: TextureButton):
	if button:
		button.texture_normal = baseIcons[button.name]

func pressed_icon(button: TextureButton):
	reset_icon(current_button)
	current_button = button
	button.texture_normal = activeIcons[button.name]
	TabName.get_node("Label").text = iconTitles[button.name]
	clean_VContainer()

	if button == Units:
		generate_units()
	elif button == Traps:
		generate_traps()
	elif button == Fields:
		generate_fields()

	SidePanel.visible = false

func clean_VContainer():
	for button in VContainer.get_children():
		if button != Template:
			button.queue_free()

func generate_units():
	for unit in units.keys():
		var info = units[unit]
		var is_unlocked = Player.is_unit_unlocked(unit)
		
		var new_button = Template.duplicate()
		new_button.name = unit
		new_button.visible = true
		
		var icon_instance = info.Icon.instantiate()
		var icon_marker = new_button.get_node("IconMarker")
		new_button.add_child(icon_instance)
		icon_instance.position = icon_marker.position
		
		if is_unlocked:
			new_button.get_node("Locked").visible = false
			new_button.get_node("Amount").visible = true
			new_button.get_node("Amount").text = str(Player.get_unit_amount(unit))
			new_button.get_node("Cost").text = str(info.Cost)
			
			create_placement_unit_icon(unit)
		else:
			new_button.get_node("Locked").visible = true
			new_button.get_node("Amount").visible = false
			new_button.get_node("Cost").text = str(info.UnlockCost)
		
		new_button.pressed.connect(func():
			var currently_unlocked = Player.is_unit_unlocked(unit)

			SidePanel.visible = true
			SidePanel.get_node("ThingName/Label").text = unit
			SidePanel.get_node("Description/Label").text = info.LoreDescription
			SidePanel.get_node("UseName/Label").text = "Skill"
			SidePanel.get_node("UseDescription/Label").text = info.SkillsDescription

			if currently_unlocked:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
				SidePanel.get_node("SoulsBackground/Label").text = "Buy"
			else:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.UnlockCost)
				SidePanel.get_node("SoulsBackground/Label").text = "Unlock"

			clean_side_panel_character()

			if ally_characters.has(unit):
				var offset = 0
				if info.has("VisualOffset"):
					offset = info.VisualOffset
				
				var ally_character = ally_characters[unit].instantiate()
				ally_character.global_position = SidePanel.get_node("Character/CharacterSpot").global_position + Vector2(offset,0)
				ally_character.get_node("GUI").visible = false
				ally_character.breath_duration_variance = 0.0
				ally_character.z_index = 1
				SidePanel.get_node("Character").add_child(ally_character)
		)
		
		VContainer.add_child(new_button)
		
func clean_side_panel_character():
	for child in SidePanel.get_node("Character").get_children():
		if child.name != "CharacterSpot":
			child.queue_free()

func update_unit_amount(unit: String, new_amount):
	var unit_node = VContainer.get_node_or_null(unit)
	if unit_node:
		unit_node.get_node("Amount").text = str(new_amount)

	var units_hud_icon = UnitsHudContainer.get_node_or_null(unit)
	if not units_hud_icon:
		print("Units hud icon for ", unit, " not found")
		return

	units_hud_icon.get_node("Amount").text = str(new_amount)

func purchase_unit(unit: String):
	var info = units[unit]
	if Player.is_unit_unlocked(unit):
		var result = Player.remove_souls(info.Cost)
		if result:
			var new_amount = Player.add_unit(unit)
			if not new_amount:
				print("newAmount is null")
				return
			update_unit_amount(unit, new_amount)
	else:
		var result = Player.remove_souls(info.UnlockCost)
		if result:
			var unlock_result = Player.unlock_unit(unit)
			if not unlock_result:
				print("unlock_result is null")
				return

			create_placement_unit_icon(unit)
			
			var initial_amount = Player.add_unit(unit)
			update_unit_amount(unit, initial_amount)
			
			SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
			SidePanel.get_node("SoulsBackground/Label").text = "Buy"

			var unit_node = VContainer.get_node_or_null(unit)
			if not unit_node:
				clean_VContainer()
				generate_units()
				return

			unit_node.get_node("Amount").visible = true
			unit_node.get_node("Locked").visible = false
			unit_node.get_node("Cost").text = str(info.Cost)

func create_placement_unit_icon(unit):
	if UnitsHudContainer.get_node_or_null(NodePath(unit)):
		return
	
	var info = units[unit]
	var new_button = UnitsHudTemplate.duplicate()
	new_button.name = unit
	new_button.visible = true
	
	new_button.get_node("Amount").visible = true
	new_button.get_node("Amount").text = str(Player.get_unit_amount(unit))
	new_button.get_node("Cost").text = str(info.Cost)
	
	var icon_instance = info.Icon.instantiate()
	var icon_marker = new_button.get_node("IconMarker")
	new_button.add_child(icon_instance)
	icon_instance.position = icon_marker.position
	
	new_button.button_down.connect(func():
		if Player.get_unit_amount(unit) == 0:
			purchase_unit(unit)

		var result = Player.remove_unit(unit)
		
		if result == null:
			print("Removing failed for ", unit)
			return
			
		update_unit_amount(unit, result)
		
		currently_dragging = info.Chibi.instantiate()
		ChibiPlace.add_child(currently_dragging)
	)
	
	new_button.button_up.connect(func():
		var placed = false
		if currently_dragging:
			for flag in get_tree().get_nodes_in_group("Flag"):
				var distance = currently_dragging.global_position.distance_to(flag.global_position)
				print("Checking ", flag, " with distance ", distance)
				if distance <= FLAG_DROP_RANGE:
					flag.add_unit(unit, info)
					placed = true
					print("Found place")
					break
			
			if not placed:
				var result = Player.add_unit(unit)
				update_unit_amount(unit, result)
			
			currently_dragging.queue_free()
			currently_dragging = null
	)
	
	UnitsHudContainer.add_child(new_button)
	
func generate_traps():
	for trap in traps.keys():
		var info = traps[trap]
		var is_unlocked = Player.is_trap_unlocked(trap)

		var new_button = Template.duplicate()
		new_button.name = trap
		new_button.visible = true
		var icon_instance = info.Icon.instantiate()
		var icon_marker = new_button.get_node("IconMarker")
		new_button.add_child(icon_instance)
		icon_instance.position = icon_marker.position

		if is_unlocked:
			new_button.get_node("Locked").visible = false
			new_button.get_node("Amount").visible = true
			new_button.get_node("Amount").text = str(Player.get_trap_amount(trap))
			new_button.get_node("Cost").text = str(info.Cost)

			create_placement_trap_icon(trap)
		else:
			new_button.get_node("Locked").visible = true
			new_button.get_node("Amount").visible = false
			new_button.get_node("Cost").text = str(info.UnlockCost)

		new_button.pressed.connect(func():
			clean_side_panel_character()
			
			SidePanel.visible = true
			SidePanel.get_node("ThingName/Label").text = trap
			SidePanel.get_node("Description/Label").text = info.LoreDescription
			SidePanel.get_node("UseName/Label").text = "Effect"
			SidePanel.get_node("UseDescription/Label").text = info.SkillsDescription

			if is_unlocked:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
				SidePanel.get_node("SoulsBackground/Label").text = "Buy"
			else:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.UnlockCost)
				SidePanel.get_node("SoulsBackground/Label").text = "Unlock"
		)

		VContainer.add_child(new_button)

func update_trap_amount(trap: String, new_amount):
	var trap_node = VContainer.get_node_or_null(trap)
	if trap_node:
		trap_node.get_node("Amount").text = str(new_amount)

	var traps_hud_icon = TrapsHudContainer.get_node_or_null(NodePath(trap))
	if not traps_hud_icon:
		print("Traps hud icon for ", trap, " not found")
		return

	traps_hud_icon.get_node("Amount").text = str(new_amount)

func purchase_trap(trap: String):
	var info = traps[trap]
	if Player.is_trap_unlocked(trap):
		var result = Player.remove_souls(info.Cost)
		if result:
			var new_amount = Player.add_trap(trap)

			if not new_amount:
				print("new_amount is null")
				return

			update_trap_amount(trap, new_amount)
	else:
		var result = Player.remove_souls(info.UnlockCost)
		if result:
			var unlock_result = Player.unlock_trap(trap)

			if not unlock_result:
				print("unlock_result is null")
				return

			create_placement_trap_icon(trap)
			var initial_amount = Player.add_trap(trap)
			update_trap_amount(trap, initial_amount)

			SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
			SidePanel.get_node("SoulsBackground/Label").text = "Buy"

			var trap_node = VContainer.get_node_or_null(trap)

			if not trap_node:
				print("Trap node for ", trap, " not found")
				return

			trap_node.get_node("Amount").visible = true
			trap_node.get_node("Locked").visible = false
			trap_node.get_node("Cost").text = str(info.Cost)

func create_placement_trap_icon(trap: String):
	if TrapsHudContainer.get_node_or_null(NodePath(trap)):
		return

	var info = traps[trap]
	var new_button = TrapsHudTemplate.duplicate()
	new_button.name = trap
	new_button.visible = true

	var icon_instance = info.Icon.instantiate()
	var icon_marker = new_button.get_node("IconMarker")
	new_button.add_child(icon_instance)
	icon_instance.position = icon_marker.position
	new_button.get_node("Amount").visible = true
	new_button.get_node("Amount").text = str(Player.get_trap_amount(trap))
	new_button.get_node("Cost").text = str(info.Cost)

	new_button.button_down.connect(func():
		if Player.get_trap_amount(trap) == 0:
			purchase_trap(trap)

		var result = Player.remove_trap(trap)

		if result == null:
			print("Removing failed for ", trap)
			return

		update_trap_amount(trap, result)

		currently_dragging = info.Scene.instantiate()
		currently_dragging.visible = true
		ChibiPlace.add_child(currently_dragging)

		create_trap_preview()
	)

	new_button.button_up.connect(func():
		if currently_dragging:
			var nearest = get_nearest_floor_tile(get_local_mouse_position())
			var placed = false

			if nearest and not is_tile_occupied(nearest):
				print("Placed trap at ", nearest)
				currently_dragging.global_position = nearest.global_position
				currently_dragging.visible = true
				currently_dragging.set_meta("tile", nearest)
				currently_dragging.set_meta("trap_name", trap)
				currently_dragging.add_to_group("PlacedTraps")
				
				placed = true
				
				play_sound(TrapPlaceSound)
				
				var tile_parent = nearest.get_parent()
				ChibiPlace.remove_child(currently_dragging)
				tile_parent.add_child(currently_dragging)
				
				var trap_placed = currently_dragging

				currently_dragging.get_node("ClickBox").input_event.connect(func(viewport, event, shape_idx):
					if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						if EnemyManager.dungeon_state == "CLOSED":
							trap_clicked(trap_placed)
				)

			if not placed:
				var result = Player.add_trap(trap)
				update_trap_amount(trap, result)
				currently_dragging.queue_free()

			clear_trap_preview()
			currently_dragging = null
	)

	TrapsHudContainer.add_child(new_button)
	
func trap_clicked(trap_node: Node):
	if not trap_node.has_meta("trap_name"):
		print("Couldn't find trap name")
		return

	var trap_name = trap_node.get_meta("trap_name")

	trap_node.remove_from_group("PlacedTraps")
	trap_node.queue_free()

	var result = Player.add_trap(trap_name)
	update_trap_amount(trap_name, result)

func _on_shop_opener_pressed() -> void:
	if not visible:
		if not SaveManager.has_seen_dialogue("tutorial3"):
			SaveManager.mark_dialogue_seen("tutorial3")
			DialogueManager.start("tutorial3")
		top_bar_visibility = TopBar.visible
		TopBar.visible = false
		DungeonOpener.visible = false
	else:
		TopBar.visible = top_bar_visibility
		DungeonOpener.visible = true
	visible = not visible

func _on_souls_background_pressed() -> void:
	var thing_name = SidePanel.get_node("ThingName/Label").text

	if thing_name in units:
		purchase_unit(thing_name)
	elif thing_name in traps:
		purchase_trap(thing_name)
	elif thing_name in fields:
		purchase_field(thing_name)
	else:
		print(thing_name, " doesn't exist")

#func _on_units_opener_pressed() -> void:
	#if not visible:
		#TopBar.visible = not TopBar.visible

func flag_removed_unit(unit):
	var result = Player.add_unit(unit)
	update_unit_amount(unit, result)
	
	
func get_nearest_floor_tile(pos: Vector2):
	var max_distance = 90
	var nearest = null
	var nearest_dist = INF
	for tile in get_tree().get_nodes_in_group("FloorTile"):
		if tile.get_parent() == FloorHandler.floors[FloorHandler.current_floor]:
			var dist = pos.distance_to(tile.position)
			if dist <= max_distance and dist < nearest_dist:
				nearest_dist = dist
				nearest = tile
	return nearest

func is_tile_occupied(tile: Node) -> bool:
	for existing in get_tree().get_nodes_in_group("PlacedTraps"):
		if existing.get_meta("tile") == tile:
			return true
	return false

func update_trap_preview():
	if not placement_preview:
		return

	var mouse_pos = get_local_mouse_position()

	if mouse_pos != last_mouse_pos:
		last_mouse_pos = mouse_pos
		cached_nearest_tile = get_nearest_floor_tile(mouse_pos)

	if not cached_nearest_tile:
		placement_preview.visible = false
		return

	placement_preview.visible = true
	placement_preview.global_position = cached_nearest_tile.global_position

	if is_tile_occupied(cached_nearest_tile):
		placement_preview.color = Color(1, 0, 0, 0.4)
	else:
		placement_preview.color = Color(0, 1, 0, 0.4)

func create_trap_preview():
	placement_preview = Polygon2D.new()
	placement_preview.polygon = PackedVector2Array([
		Vector2(0, -48),   # top
		Vector2(77, 0),    # right
		Vector2(0, 48),    # bottom
		Vector2(-77, 0)    # left
	])
	placement_preview.color = Color(0, 1, 0, 0.4)
	get_tree().root.add_child(placement_preview)

func clear_trap_preview():
	if placement_preview:
		placement_preview.queue_free()
		placement_preview = null

func load_unit_assets():
	var chibi_dir = "res://Prefabs/Chibis/"
	var icon_dir = "res://Prefabs/Icons/"

	for unit in units.keys():
		var chibi_path = chibi_dir + unit + ".tscn"
		var chibi_remap = chibi_path + ".remap"
		if ResourceLoader.exists(chibi_path) or ResourceLoader.exists(chibi_remap):
			units[unit]["Chibi"] = ResourceLoader.load(chibi_path)
		else:
			units[unit]["Chibi"] = ResourceLoader.load("res://Prefabs/Chibis/placeholder.tscn")

		var icon_path = icon_dir + unit + ".tscn"
		var icon_remap = icon_path + ".remap"
		if ResourceLoader.exists(icon_path) or ResourceLoader.exists(icon_remap):
			units[unit]["Icon"] = ResourceLoader.load(icon_path)
		else:
			units[unit]["Icon"] = ResourceLoader.load("res://Sprites/HUD/Shop/placeh.png")

func update_all_amounts():
	SidePanel.visible = false
	clean_side_panel_character()

	if current_button == Units:
		clean_VContainer()
		generate_units()
	elif current_button == Traps:
		clean_VContainer()
		generate_traps()
	elif current_button == Fields:
		clean_VContainer()
		generate_fields()
	
	for unit in units.keys():
		if Player.is_unit_unlocked(unit):
			var amount = Player.get_unit_amount(unit)
			var hud_icon = UnitsHudContainer.get_node_or_null(NodePath(unit))
			if hud_icon:
				hud_icon.get_node("Amount").text = str(amount)
		else:
			var hud_icon = UnitsHudContainer.get_node_or_null(NodePath(unit))
			if hud_icon:
				hud_icon.queue_free()

	for trap in traps.keys():
		if Player.is_trap_unlocked(trap):
			var amount = Player.get_trap_amount(trap)
			var hud_icon = TrapsHudContainer.get_node_or_null(NodePath(trap))
			if hud_icon:
				hud_icon.get_node("Amount").text = str(amount)
		else:
			var hud_icon = TrapsHudContainer.get_node_or_null(NodePath(trap))
			if hud_icon:
				hud_icon.queue_free()

	for field in fields.keys():
		if Player.is_field_unlocked(field):
			var amount = Player.get_field_amount(field)
			var hud_icon = FieldsHudContainer.get_node_or_null(NodePath(field))
			if hud_icon:
				hud_icon.get_node("Amount").text = str(amount)
		else:
			var hud_icon = FieldsHudContainer.get_node_or_null(NodePath(field))
			if hud_icon:
				hud_icon.queue_free()

func generate_fields():
	for field in fields.keys():
		var info = fields[field]
		var is_unlocked = Player.is_field_unlocked(field)

		var new_button = Template.duplicate()
		new_button.name = field
		new_button.visible = true
		var icon_instance = info.Icon.instantiate()
		var icon_marker = new_button.get_node("IconMarker")
		new_button.add_child(icon_instance)
		icon_instance.position = icon_marker.position

		if is_unlocked:
			new_button.get_node("Locked").visible = false
			new_button.get_node("Amount").visible = true
			new_button.get_node("Amount").text = str(Player.get_field_amount(field))
			new_button.get_node("Cost").text = str(info.Cost)
			create_placement_field_icon(field)
		else:
			new_button.get_node("Locked").visible = true
			new_button.get_node("Amount").visible = false
			new_button.get_node("Cost").text = str(info.UnlockCost)

		new_button.pressed.connect(func():
			clean_side_panel_character()
			SidePanel.visible = true
			SidePanel.get_node("ThingName/Label").text = field
			SidePanel.get_node("Description/Label").text = info.LoreDescription
			SidePanel.get_node("UseName/Label").text = "Effect"
			SidePanel.get_node("UseDescription/Label").text = info.SkillsDescription

			if is_unlocked:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
				SidePanel.get_node("SoulsBackground/Label").text = "Buy"
			else:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.UnlockCost)
				SidePanel.get_node("SoulsBackground/Label").text = "Unlock"
		)

		VContainer.add_child(new_button)

func update_field_amount(field: String, new_amount):
	var field_node = VContainer.get_node_or_null(field)
	if field_node:
		field_node.get_node("Amount").text = str(new_amount)

	var fields_hud_icon = FieldsHudContainer.get_node_or_null(NodePath(field))
	if not fields_hud_icon:
		print("Fields hud icon for ", field, " not found")
		return

	fields_hud_icon.get_node("Amount").text = str(new_amount)

func purchase_field(field: String):
	var info = fields[field]
	if Player.is_field_unlocked(field):
		var result = Player.remove_souls(info.Cost)
		if result:
			var new_amount = Player.add_field(field)
			if not new_amount:
				print("new_amount is null")
				return
			update_field_amount(field, new_amount)
	else:
		var result = Player.remove_souls(info.UnlockCost)
		if result:
			var unlock_result = Player.unlock_field(field)
			if not unlock_result:
				print("unlock_result is null")
				return

			create_placement_field_icon(field)
			var initial_amount = Player.add_field(field)
			update_field_amount(field, initial_amount)

			SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
			SidePanel.get_node("SoulsBackground/Label").text = "Buy"

			var field_node = VContainer.get_node_or_null(field)
			if not field_node:
				print("Field node for ", field, " not found")
				return

			field_node.get_node("Amount").visible = true
			field_node.get_node("Locked").visible = false
			field_node.get_node("Cost").text = str(info.Cost)

func create_placement_field_icon(field: String):
	if FieldsHudContainer.get_node_or_null(NodePath(field)):
		return

	var info = fields[field]
	var new_button = FieldsHudTemplate.duplicate()
	new_button.name = field
	new_button.visible = true

	var icon_instance = info.Icon.instantiate()
	var icon_marker = new_button.get_node("IconMarker")
	new_button.add_child(icon_instance)
	icon_instance.position = icon_marker.position
	new_button.get_node("Amount").visible = true
	new_button.get_node("Amount").text = str(Player.get_field_amount(field))
	new_button.get_node("Cost").text = str(info.Cost)

	new_button.button_down.connect(func():
		if Player.get_field_amount(field) == 0:
			purchase_field(field)

		var result = Player.remove_field(field)
		if result == null:
			print("Removing failed for ", field)
			return

		update_field_amount(field, result)

		currently_dragging = info.Scene.instantiate()
		currently_dragging.visible = true
		ChibiPlace.add_child(currently_dragging)

		create_field_preview()
	)

	new_button.button_up.connect(func():
		if currently_dragging:
			var nearest = get_nearest_flag_tile(get_local_mouse_position())
			var placed = false

			if nearest and not is_flag_tile_occupied(nearest):
				currently_dragging.global_position = nearest.global_position
				currently_dragging.visible = true
				currently_dragging.set_meta("tile", nearest)
				currently_dragging.set_meta("field_name", field)
				currently_dragging.add_to_group("PlacedFields")
				
				var flag = nearest.get_node(nearest.get_meta("Flag"))
				flag.field = field

				placed = true
				
				play_sound(FieldPlaceSound)

				var tile_parent = nearest.get_parent()
				ChibiPlace.remove_child(currently_dragging)
				tile_parent.add_child(currently_dragging)

				var field_placed = currently_dragging
				currently_dragging.get_node("ClickBox").input_event.connect(func(viewport, event, shape_idx):
					if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						if EnemyManager.dungeon_state == "CLOSED":
							field_clicked(field_placed)
				)

			if not placed:
				var result = Player.add_field(field)
				update_field_amount(field, result)
				currently_dragging.queue_free()

			clear_field_preview()
			currently_dragging = null
	)

	FieldsHudContainer.add_child(new_button)

func field_clicked(field_node: Node):
	if not field_node.has_meta("field_name"):
		print("Couldn't find field name")
		return
		
	var tile = field_node.get_meta("tile")
	var flag = tile.get_node(tile.get_meta("Flag"))
	flag.field = ""

	var field_name = field_node.get_meta("field_name")
	field_node.remove_from_group("PlacedFields")
	field_node.queue_free()

	var result = Player.add_field(field_name)
	update_field_amount(field_name, result)

func get_nearest_flag_tile(pos: Vector2):
	var max_distance = 90
	var nearest = null
	var nearest_dist = INF
	for tile in get_tree().get_nodes_in_group("FlagTile"):
		var dist = pos.distance_to(tile.position)
		if dist <= max_distance and dist < nearest_dist:
			nearest_dist = dist
			nearest = tile
	return nearest
	
func create_field_preview():
	field_placement_preview = Polygon2D.new()
	field_placement_preview.polygon = PackedVector2Array([
		Vector2(0, -48),
		Vector2(77, 0),
		Vector2(0, 48),
		Vector2(-77, 0)
	])
	field_placement_preview.color = Color(0, 1, 0, 0.4)
	get_tree().root.add_child(field_placement_preview)

func clear_field_preview():
	if field_placement_preview:
		field_placement_preview.queue_free()
		field_placement_preview = null

func update_field_preview():
	if not field_placement_preview:
		return

	var mouse_pos = get_local_mouse_position()

	if mouse_pos != last_mouse_pos_field:
		last_mouse_pos_field = mouse_pos
		cached_nearest_flag_tile = get_nearest_flag_tile(mouse_pos)

	if not cached_nearest_flag_tile:
		field_placement_preview.visible = false
		return

	field_placement_preview.visible = true
	field_placement_preview.global_position = cached_nearest_flag_tile.global_position

	if is_flag_tile_occupied(cached_nearest_flag_tile):
		field_placement_preview.color = Color(1, 0, 0, 0.4)
	else:
		field_placement_preview.color = Color(0, 1, 0, 0.4)

func is_flag_tile_occupied(tile: Node) -> bool:
	for existing in get_tree().get_nodes_in_group("PlacedFields"):
		if existing.get_meta("tile") == tile:
			return true
	return false

func rebuild_placement_icons() -> void:
	for unit in units.keys():
		if Player.is_unit_unlocked(unit):
			create_placement_unit_icon(unit)
	for trap in traps.keys():
		if Player.is_trap_unlocked(trap):
			create_placement_trap_icon(trap)
	for field in fields.keys():
		if Player.is_field_unlocked(field):
			create_placement_field_icon(field)

func play_sound(stream) -> void:
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = stream
	audio.play()
	audio.finished.connect(audio.queue_free)
