package main
import "core:fmt"
import "core:mem"
import "core:os"
import rl "vendor:raylib"

Editor :: struct {
	ch:     ^u8,
	offset: uint,
	buffer: [1024]u8,
}

initEditor :: proc() -> Editor {
	ch: ^u8
	buffer: [1024]u8
	return {ch = ch, offset = 0, buffer = buffer}
}

saveEditor :: proc(editor: ^Editor, filename: string) {
	ok := os.write_entire_file(filename, editor.buffer[:])
	if !ok do panic("File writing failed.\n")
	fmt.printf("File saved\n")
}

handleKey :: proc(editor: ^Editor, key: rl.KeyboardKey) {
	if key != .KEY_NULL && editor.offset < len(editor.buffer) - 1 {
		shift := rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT)
		ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
		#partial switch key {
		case .SPACE:
			editor.buffer[editor.offset] = ' '
			editor.offset += 1
		case .ENTER:
			editor.buffer[editor.offset] = '\n'
			editor.offset += 1
		case .A ..= .Z:
			if shift {
				editor.buffer[editor.offset] = auto_cast key
			} else {
				if ctrl && key == .S {
					saveEditor(editor, "data.text")
				} else {
					editor.buffer[editor.offset] = auto_cast key + 32
				}
			}
			editor.offset += 1
		case .BACKSPACE:
			if editor.offset > 0 {
				editor.buffer[editor.offset - 1] = 0
				editor.offset -= 1
			}
		case .ZERO, .ONE, .TWO, .THREE, .FOUR, .FIVE, .SIX, .SEVEN, .EIGHT, .NINE:
			editor.buffer[editor.offset] = auto_cast key
			editor.offset += 1
		case .LEFT_SHIFT, .RIGHT_SHIFT, .LEFT_ALT, .RIGHT_ALT, .LEFT_SUPER, .RIGHT_SUPER:
		case:
			editor.buffer[editor.offset] = auto_cast key
			editor.offset += 1
		}
	}
}

main :: proc() {
	rl.InitWindow(1066, 600, "")
	font := rl.LoadFontEx("./Meslo.ttf", 32, nil, 0)
	editor := initEditor()
	editor.ch = &editor.buffer[0]
	for !rl.WindowShouldClose() {
		key := rl.GetKeyPressed()
		handleKey(&editor, key)
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText(auto_cast editor.ch, 10, 10, 18, rl.BLACK)
		rl.EndDrawing()
	}
	rl.UnloadFont(font)
	rl.CloseWindow()
}
