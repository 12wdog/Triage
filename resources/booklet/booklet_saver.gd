@tool
extends EditorScript

const export : String = "res://presaved/booklet/book.tres"

var book := Book.new([
"[b][i]Antibiotics[/i][/b]
• [b]LE[/b] for [i]Infection[/i]

[b][i]Bandage[/i][/b]
• [b]HE[/b] for [i]Light Bleeding[/i]
• [b]LE[/b] for [i]Heavy Bleeding[/i]
	• [b]HE[/b] when used with [u]Stitches[/u]
• [b]LE[/b] when used with [u]Serum[/u] for [i]Infection[/i]
	• [b]ME[/b] when used with [u]Antibiotics[/u]
	• [b]HE[/b] when used with [u]Serum[/u] and [u]Antibiotics[/u]
• [b]LE[/b] for [i]Bullet Wound[/i]
	• [b]ME[/b] when used with [u]Tongs[/u]
	• [b]HE[/b] when used with [u]Tongs[/u] and [u]Stitches[/u]
• [b]HE[/b] when used with [u]Serum[/u] for [i]Second Degree Burns[/i]

[b][i]Bone Saw[/i][/b]
• [b]GUARANTEED TO CURE ANYTHING, BUT HIGH RISK OF SHOCK OR DEATH[/b] 

[b][i]Serum[/i][/b]
• [b]HE[/b] for [i]First Degree Burns[/i]
",
"[b][i]Splint[/i][/b]
• [b]ME[/b] for [i]Broken Bone[/i]

[b][i]Stitches[/i][/b]
• [b]ME[/b] when used with [u]Surgery[/u] for [i]Internal Bleeding[/i]
• [b]ME[/b] for [i]Bullet Wound[/i]
	• [b]HE[/b] when used with [u]Tongs[/u]
	
[b][i]Surgery[/i][/b]
• [b]ME[/b] for [i]Broken Bone[/i]
	• [b]HE[/b] when used with [u]Splint[/u]
• [b]ME[/b] for [i]Necrosis[/i]
	• [b]HE[/b] when used with [u]Antibiotics[/u]
• [b]LE[/b] for [i]Shock[/i]
	• [b]WARNING![/b] High risk of [b]PATIENT DEATH[/b]

[b][i]Painkiller[/i][/b]
• [b]LE[/b] for [i]Light Bleeding[/i], [i]Infection[/i], and [i]Bullet Wounds[/i], 
	• [b]ME[/b] If used again. [b]RISK OF OVERDOSE![/b]
• [b]ME[/b] for [i]Shock[/i]
	• [b]HE[/b] If used again. [b]RISK OF OVERDOSE![/b]
",
"[b][i]Light Bleeding[/i][/b]
• [b]LE[/b] for [u]Painkiller[/u]
	• [b]ME[/b] If used again.
• [b]HE[/b] for [u]Bandage[/u]

[b][i]Heavy Bleeding[/i][/b]
• [b]LE[/b] for [u]Bandage[/u]
	• [b]HE[/b] for [u]Stitches[/u] then [u]Bandage[/u]

[b][i]Internal Bleeding[/i][/b]
• [b]ME[/b] for [u]Surgery[/u] then [u]Stitches[/u]

[b][i]Infection[/i][/b]
• [b]LE[/b] for [u]Painkiller[/u] or [u]Antibiotics[/u]
• [b]LE[/b] for [u]Serum[/u] then [u]Bandage[/u]
• [b]ME[/b] when used with [u]Antibiotics[/u] then [u]Bandage[/u]
	• [b]HE[/b] when used with [u]Serum[/u] and [u]Antibiotics[/u] then [u]Bandage[/u]
",
"[b][i]Bullet Wound[/i][/b]
• [b]LE[/b] for [u]Bandage[/u]
	• [b]ME[/b] for [u]Tongs[/u] then [u]Bandage[/u]
	• [b]HE[/b] for [u]Tongs[/u] and [u]Stitches[/u] then [u]Bandage[/u]
• [b]ME[/b] for [u]Stitches[/u]
	• [b]HE[/b] for[u]Tongs[/u] then [u]Stitches[/u]

[b][i]First Degree Burn[/i][/b]
• [b]HE[/b] for [u]Serum[/u]

[b][i]Second Degree Burn[/i][/b]
• [b]HE[/b] for [u]Serum[/u] then [u]Bandage[/u]

[b][i]Broken Bone[/i][/b]
• [b]ME[/b] for [u]Splint[/u]
• [b]ME[/b] for [u]Surgery[/u]
	• [b]ME[/b] for [u]Splint[/u] then [u]Surgery[/u]

[b][i]Shock[/i][/b]
• [b]LE[/b] for [u]Surgery[/u]
• [b]ME[/b] for [u]Painkiller[/u]
	• [b]HE[/b] If used again. [b]RISK OF OVERDOSE![/b]

[b][i]Necrosis[/i][/b]
• [b]ME[/b] for [u]Surgery[/u]
	• [b]HE[/b] for [u]Antibiotics[/u] then [u]Surgery[/u]
"
])

func _run() -> void:
	ResourceSaver.save(book, export)
