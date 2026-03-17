extends Node

const WEAKENED_DAMAGE_REDUCTION = 0.75
const POWERFUL_DAMAGE_INCREASE = 1.25
const RIPOSTE_CHANCE = 50
const TANGO_DODGE_CHANCE = 50

func do_damage(attacker, victim, damage, status):
	if victim.is_dead == true:
		return
	var dodge_chance = 0
	
	if victim.has_meta("SwiftMoves") and victim.get_meta("SwiftMoves") == true:
		dodge_chance += 10
	
	var attacker_status = attacker.get_node_or_null("Status")
	
	if attacker_status:
		var weakened = attacker_status.get_node_or_null("Weakened")
		var powerful = attacker_status.get_node_or_null("Powerful")
		
		if weakened:
			damage *= WEAKENED_DAMAGE_REDUCTION
		
		if powerful:
			damage *= POWERFUL_DAMAGE_INCREASE
			
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
				
		if tango:
			dodge_chance += TANGO_DODGE_CHANCE
			
	if dodge_chance > 0:
		if randi_range(1,100) <= dodge_chance:
			return
				
	for status_name in status:
		var amount = status[status_name]
		
		StatusHandler.apply_status(victim, status_name, amount)
	
	victim.take_damage(damage)


func counter_attack(attacker, victim):
	var attack = victim.get_node_or_null("Moves/Attack")
	
	if attack:
		attack.use(attacker)
