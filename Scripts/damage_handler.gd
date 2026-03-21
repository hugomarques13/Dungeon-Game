extends Node

const WEAKENED_DAMAGE_REDUCTION = 0.75
const POWERFUL_DAMAGE_INCREASE = 1.25
const RIPOSTE_CHANCE = 50
const TANGO_DODGE_CHANCE = 50
const READIED_CRIT_CHANCE = 25

const BASE_CRIT_CHANCE = 10
const BASE_CRIT_DAMAGE = 1.5

var CounterSound = preload("res://Sounds/Counter.wav")
var DodgeSound = preload("res://Sounds/Dodge.mp3")

func do_damage(attacker, victim, damage, status, soul_multiplier: float = 1.0):
	if not victim or not attacker or victim.is_dead == true:
		return
	var dodge_chance = 0
	var crit_chance = BASE_CRIT_CHANCE
	var is_crit = false
	
	if victim.has_meta("SwiftMoves") and victim.get_meta("SwiftMoves") == true:
		dodge_chance += 10
	
	var attacker_status = attacker.get_node_or_null("Status")
	
	if attacker_status:
		var weakened = attacker_status.get_node_or_null("Weakened")
		var powerful = attacker_status.get_node_or_null("Powerful")
		var readied = attacker_status.get_node_or_null("Readied")
		
		if weakened:
			damage *= WEAKENED_DAMAGE_REDUCTION
		
		if powerful:
			damage *= POWERFUL_DAMAGE_INCREASE
			
		if readied and damage > 0:
			crit_chance += READIED_CRIT_CHANCE
			
	var victim_status = victim.get_node_or_null("Status")
	
	if victim_status:
		var mark = victim_status.get_node_or_null("Mark")
		var riposte = victim_status.get_node_or_null("Riposte")
		var tango = victim_status.get_node_or_null("Tango")
		
		if mark:
			damage += 3
			
		if riposte:
			if randi_range(1,100) <= RIPOSTE_CHANCE:
				counter_attack(attacker, victim)
				victim.create_text_indicator("COUNTER", Color(0.771, 0.696, 0.0, 1.0))
				
		if tango:
			dodge_chance += TANGO_DODGE_CHANCE
			
	if dodge_chance > 0:
		if randi_range(1,100) <= dodge_chance:
			play_sound(victim, DodgeSound)
			victim.create_text_indicator("DODGED", Color(0.316, 0.558, 0.0, 1.0))
			return
				
	for status_name in status:
		var amount = status[status_name]
		
		StatusHandler.apply_status(victim, status_name, amount)
		
	if randi_range(1,100) <= crit_chance:
		damage *= BASE_CRIT_DAMAGE
		is_crit = true
		
	damage = floor(damage)
	
	victim.take_damage(damage, is_crit, soul_multiplier)


func counter_attack(attacker, victim):
	play_sound(victim, CounterSound)
	var attack = victim.get_node_or_null("Moves/Attack")
	
	if attack:
		attack.use(attacker)
		
func play_sound(character, sound):
	var audio = AudioStreamPlayer.new()
	character.add_child(audio)
	audio.stream = sound
	audio.play()
	audio.finished.connect(audio.queue_free)
