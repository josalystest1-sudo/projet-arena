## Sprites provisoires en pixel art, dessinés à partir de grilles de caractères.
## Ils seront remplacés par les sprites PixelLab à l'étape 5.
class_name PixelSprites
extends RefCounted

const GRID := 16

## « T » et « D » prennent la couleur de l'équipe (claire et foncée).
const PALETTE := {
	"K": Color("1a1a24"),  # contour
	"S": Color("f1c27d"),  # peau
	"E": Color("1a1a24"),  # yeux
	"M": Color("8d99ae"),  # métal
	"L": Color("d9dee6"),  # métal clair
	"G": Color("f4c542"),  # or
	"W": Color("f8f8f2"),  # blanc
	"B": Color("7a4b2a"),  # bois / cuir
	"F": Color("ff7b29"),  # flamme
	"Y": Color("ffe066"),  # flamme claire
}

const SPRITES := {
	"guerrier": [
		"................",
		".....KKKKKK.....",
		"....KMMMMMMK....",
		"....KMLLLLMK....",
		"....KMKEEKMK....",
		"....KMSSSSMK....",
		"..KK.KSSSSK.KK..",
		".KMMKTTTTTTKLLK.",
		".KMGMKTTDTTKLK..",
		".KMMMKTTDTTKLK..",
		".KMGMKTTTTTKBK..",
		"..KMKKDDDDDK.K..",
		"...K.KTTKTTK....",
		".....KTTKTTK....",
		".....KMMKMMK....",
		".....KKK.KKK....",
	],
	"mage": [
		".......KK.......",
		"......KTTK......",
		".....KTTTDK.....",
		"....KTTTTTDK....",
		"...KKKKKKKKKK...",
		".....KSSSSK..KY.",
		".....KEKSEK.KFYK",
		".....KSSSSK..KF.",
		"....KTTTTTTK.KB.",
		"...KTTGTTTTTKKB.",
		"...KTTGTTTTTSKB.",
		"...KTTTTTTTTK.B.",
		"...KTTTDTTTTK.B.",
		"..KTTTTDTTTTTKB.",
		"..KDDDDDDDDDDKB.",
		"..KKKKKKKKKKKK..",
	],
	"pretre": [
		"................",
		"......KKKK......",
		".....KWWWWK.....",
		"....KWSSSSWK....",
		"....KWEKSEWK....",
		"....KWSSSSWK....",
		".....KWWWWK..G..",
		"....KTTTTTTK.G..",
		"...KTWWGWWTKGGG.",
		"...KTWGGGWTK.G..",
		"...KTWWGWWTSKG..",
		"...KTTWWWTTK.B..",
		"...KTTTTTTTK.B..",
		"..KTTTTTTTTTKB..",
		"..KDDDDDDDDDKB..",
		"..KKKKKKKKKKKK..",
	],
}


## Dessine le sprite d'une classe sur un CanvasItem, en haut à gauche de « origin ».
static func draw(canvas: CanvasItem, class_id: String, origin: Vector2, pixel: float, team_color: Color, flip: bool = false, grey: bool = false) -> void:
	var rows: Array = SPRITES.get(class_id, SPRITES["guerrier"])
	var dark := team_color.darkened(0.35)
	for y in range(rows.size()):
		var row: String = rows[y]
		for x in range(row.length()):
			var c := row[x]
			if c == ".":
				continue
			var color: Color
			if c == "T":
				color = team_color
			elif c == "D":
				color = dark
			else:
				color = PALETTE.get(c, Color.MAGENTA)
			if grey:
				var v := color.get_luminance() * 0.6
				color = Color(v, v, v, 0.8)
			var px := (GRID - 1 - x) if flip else x
			canvas.draw_rect(Rect2(origin + Vector2(px, y) * pixel, Vector2(pixel, pixel)), color)
