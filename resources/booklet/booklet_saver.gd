@tool
extends EditorScript

const export : String = "res://presaved/booklet/book.tres"

var book := Book.new([
"[b][i]Bandage[/i][/b]
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

[b][i]Serum[/i][/b]
• [b]HE[/b] for [i]First Degree Burns[/i]

[b][i]Stitches[/i][/b]
• [b]ME[/b] when used with [u]Surgery[/u] for [i]Internal Bleeding[/i]
• [b]ME[/b] for [i]Bullet Wound[/i]
	• [b]ME[/b] when used with [u]Tongs[/u]
",
	"[b][i]Antibiotics[/i][/b]
• [b]LE[/b] for [i]Infection[/i]

[b][i]Surgery[/i][/b]
• [b]ME[/b] for [i]Broken Bone[/i]
• [b]ME[/b] for [i]Necrosis[/i]
	• [b]HE[/b] when used with [u]Antibiotics[/u]
• [b]LE[/b] for [i]Shock[/i]
	• [b]WARNING![/b] High risk of [b]PATIENT DEATH[/b]

[b][i]Bone Saw[/i][/b]
• [b]GUARANTEED TO CURE ANYTHING, BUT HIGH RISK OF SHOCK OR DEATH[/b] 

[b][i]Painkiller[/i][/b]
• [b]LE[/b] for [i]Light Bleeding[/i], [i]Infection[/i], and [i]Bullet Wounds[/i], 
	• [b]ME[/b] If used again. [b]RISK OF OVERDOSE![/b]
• [b]ME[/b] for [i]Shock[/i]
	• [b]HE[/b] If used again. [b]RISK OF OVERDOSE![/b]
"
])

func _run() -> void:
	ResourceSaver.save(book, export)
