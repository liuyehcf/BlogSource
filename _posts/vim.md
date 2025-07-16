---
title: vim
date: 2018-01-16 22:58:45
top: true
tags: 
- 原创
categories: 
- Editor
---

**阅读更多**

<!--more-->

# 1 Basic Concept

## 1.1 Mode

Three commonly used modes in Vim: **Normal mode, Insert mode, and Command-line mode**. Use `:help mode` for more details.

Normal mode, Insert mode, and Command-line mode can switch between each other, but Insert mode and Command-line mode cannot switch directly between each other.

### 1.1.1 Normal Mode

When you open a file with Vim, it starts in Normal mode (this is the default mode).

In this mode, you can use the arrow keys to move the cursor, delete characters or entire lines, and copy and paste content in your file.

### 1.1.2 Insert Mode

In Normal mode, you can perform operations like delete, copy, and paste, but you cannot edit the file content. You must press one of the keys like `i(I)`, `o(O)`, `a(A)`, or `r(R)` to enter Insert mode.

To return to Normal mode, simply press the `Esc` key to exit the editor mode.

### 1.1.3 Visual Mode

This mode is used for selecting and manipulating text visually.

### 1.1.4 Command-line Mode

In Normal mode, pressing any of the keys `:`, `/`, or `?` will move the cursor to the bottom line. This enters Command-line mode, where you can perform search operations.

Actions like reading and saving files, bulk character replacement, exiting Vim, displaying line numbers, and more are also carried out in this mode.

### 1.1.5 Ex Mode

This is an even more powerful mode than command-line mode, used for advanced editing and automation.

Ex mode, on the other hand, is a more powerful command-line mode that is entered by typing `Q` or `q:` from normal mode or insert mode

## 1.2 Buffer

**Each opened file corresponds to a buffer. A buffer can be visible or hidden.**

## 1.3 Window

**A window is the interface we see and interact with. A window can contain one or more buffers, but it always displays one buffer (a file or an empty one). Multiple windows can be opened simultaneously.**

## 1.4 Tab

**A tab can contain one or more windows. If multiple tabs exist, they will be displayed at the top, similar to a modern editor like VSCode.**

# 2 Operation Manual

![vi-vim-cheat-sheet](/images/vim/vi-vim-cheat-sheet.gif)

* [Where this image comes from](http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html)

## 2.1 Insert Mode

* **`i,I`**: Enter Insert mode; `i` inserts at the cursor position, `I` inserts at the first non-blank character of the current line.
* **`a,A`**: Enter Insert mode; `a` inserts after the cursor position, `A` inserts at the end of the current line.
* **`o,O`**: Enter Insert mode; `o` opens a new line below the current line, `O` opens a new line above the current line.
* **`s,S`**: Enter Insert mode; `s` deletes the character under the cursor, `S` deletes the entire current line.
* **`r,R`**: Enter Replace mode; `r` replaces the single character under the cursor once, `R` continuously replaces characters on the current line until `Esc` is pressed.
* **`Esc`**: Return to Normal mode.
* **`[Ctrl] + [`** (`:help i_CTRL-[`): Return to Normal mode.
* **`[Ctrl] + w`** (`:help i_CTRL-W`): Delete the previous word.
* **`[Ctrl] + r + [reg]`**: Insert content from a register, for example:
    * `[Ctrl] + r + 0`: Insert content from register `0`.
    * `[Ctrl] + r + "`: Insert content from the default register.
* **`[Ctrl] + r + =`**: Insert the result of an expression; expression follows the equal sign.
* **`[Ctrl] + r + /`**: Insert the last searched keyword.
* **`[Ctrl] + o + [cmd]`**: Temporarily exit Insert mode to execute a single command, then return to Insert mode.
    * `[Ctrl] + o + 0`: Move cursor to the beginning of the line, equivalent to `0` in Normal mode.
* **`[Ctrl] + d/t/f`**: Decrease/Increase/Adjust indentation of the current line.
* **`[Shift] + [Left]`**: Move cursor left by one word.
* **`[Shift] + [Right]`**: Move cursor right by one word.
* **`[Shift] + [Up]`**: Page up.
* **`[Shift] + [Down]`**: Page down.
* `[Ctrl] + e`(`:help i_CTRL-E`)：Insert the character which is below the cursor.
* `[Ctrl] + y`(`:help i_CTRL-Y`)：Insert the character which is above the cursor.

## 2.2 Moving Cursor

**Character-wise Movement:**

* `j`/`[n]j`: Move down by 1/n line.
* `k`/`[n]k`: Move up by 1/n line.
* `h`/`[n]h`: Move left by 1/n character.
* `l`/`[n]l`: Move right by 1/n character.
* `f<x>`/`[n]f<x>`: Move to the next 1/n occurrence of `<x>` in the current line.
* `F<x>`/`[n]F<x>`: Move to the previous 1/n occurrence of `<x>` in the current line.
* `t<x>`/`[n]t<x>`: Move to just before the next 1/n occurrence of `<x>` in the current line.
* `T<x>`/`[n]T<x>`: Move to just after the previous next 1/n occurrence of `<x>` in the current line.
    * `;`: Repeat the last `f/F/t/T` command.
    * `,`: Repeat the last `f/F/t/T` command in the opposite direction.
* `[n][space]`: Move right by n character.
* `0`: Move to the beginning of the line.
* `^`: Move to the first non-blank character of the line.
* `$`: Move to the end of the line.
* `g_`: Move to the last non-blank character of the line.
* `gm`: Move to the middle character of the line.

**Word-wise Movement:**

* `w`: Move to the start of the next word.
* `W`: Move to the start of the next word (words are delimited by spaces).
* `e`: Move to the end of the next word.
* `E`: Move to the end of the next word (words are delimited by spaces).
* `b`: Move to the beginning of the previous word.
* `B`: Move to the beginning of the previous word (words are delimited by spaces).
* `ge`: Move to the end of the previous word.
* `gE`: Move to the end of the previous word (words are delimited by spaces).

**Line-wise Movement:**

* `gj`: Move down by one visual line (It works with wrapped lines). 
* `gk`: Move up by one visual line (It works with wrapped lines). 
* `+`: Move to the first non-blank character of the next line.
* `-`: Move to the first non-blank character of the previous line.
* `G`: Move to the last line of the file.
* `[n]G`: Move to a specific line `<n>`.
* `gg`: Move to the first line of the file.
* `[n][Enter]`: Move to the next n lines.
* `H`: Move to the top of the screen.
* `M`: Move to the middle of the screen.
* `L`: Move to the bottom of the screen.

**Screen-wise Movement:**

* `<c-f>`: Move forward by one full screen.
* `<c-b>`: Move backward by one full screen.
* `<c-d>`: Move down by half a screen.
* `<c-u>`: Move up by half a screen.
* `<c-e>`: Scroll the screen down by one line.
* `<c-y>`: Scroll the screen up by one line.
* `zz`: Put the current line in the middle of the screen.
* `zt`: Put the current line in the top of the screen.
* `zb`: Put the current line in the bottom of the screen.

**Paragraph and Section Movement:**

* `)`: Move to next sentence.
* `(`: Move to previous sentence.
* `}`: Move to next paragraph.
* `{`: Move to previous paragraph.
* `])`: Move to next unmatched `)`.
* `[(`: Move to previous unmatched `(`.
* `]}`: Move to next unmatched `}`.
* `[{`: Move to previous unmatched `{`.
* `]m`: Move to next start of a method.
* `[m`: Move to previous start of a method.
* `]M`: Move to next end of a method.
* `[M`: Move to previous end of a method.
* `%`: Move to matched of `{} () []`.
    * You can add recognition for angle brackets `<>` by using `:set matchpairs+=<:>`. It may cause misrecognition, as the text may contain single `>` or `<`.
* `=`: Adjust indent.
    * `gg=G`

### 2.2.1 Jump List

**Help documentation: `:help jump-motions`**

**Commands that move the cursor across multiple lines are called jump commands, for example:**

* **`H`, `M`, `L`**
* **`123G`, `:123`**: Jump to the specified line
* **`/[word]`, `?[word]`, `:s`, `n`, `N`**: Search and replace
* **`%`, `()`, `[]`, `{}`**
* **`''`**: Return to the last position in the jump list; the cursor loses column info and is placed at the start of the line. This command itself is also a jump and will be recorded in the jump list.
* **`~~`**: Return to the last position in the jump list; the cursor will be positioned exactly at the previous column. This command is also a jump and will be recorded in the jump list.
* **`[Ctrl] + o`**: Return to the previous position in the jump list; this command itself is not a jump and will not be recorded in the jump list.
* **`[Ctrl] + i`**: Return to the next position in the jump list; this command itself is not a jump and will not be recorded in the jump list.
* **`:jumps`**: Display the jump list
* **`:clearjumps`**: Clear the jump list

### 2.2.2 Change List

**Help documentation: `:help changelist`**

**When content is modified, the location of the change is recorded. You can navigate between these recorded positions in the `change list` using the following commands:**

* **`g;`**: Jump to the previous position in the change list
* **`g,`**: Jump to the next position in the change list
* **`:changes`**: Display the change list

### 2.2.3 Mark

* `m<letter>`: Set a mark. Lowercase for local mark, uppercase for global mark.
* `'<letter>`: Jump to a mark.

## 2.3 Text Editing

**Commands like `c`, `d`, etc., can be combined with cursor movement commands:**

* **`dd`**: Delete the entire line where the cursor is located.
* **`dw`**: Delete from the cursor to the end of the current word.
* **`[n]dd`**: Delete the current line and the next `n-1` lines (including the current line).
* **`d1G`**: Delete from the current line up to line 1 (including the current line).
* **`dG`**: Delete from the current line to the last line (including the current line).
* **`d0`** (zero): Delete from the cursor position to the beginning of the line (excluding the character under the cursor).
* **`d^`**: Delete from the cursor position to the first non-blank character of the line (excluding the character under the cursor).
* **`d$`**: Delete from the cursor position to the end of the line (including the character under the cursor).
* **`d%`**: Delete from the character under the cursor (which must be on a bracket — `(`, `[`, or `{`) to its matching closing bracket, including all characters in between.
* **`df<x>`/`d[n]f<x>`**: Delete from the cursor position up to and including the first/nth occurrence of character `x`.
* **`dt<x>`/`d[n]t<x>`**: Delete from the cursor position up to (but not including) the first/nth occurrence of character `x`.
* **`d/<word>`**: Delete from the cursor position up to (but not including) the next occurrence of the search keyword `<word>`.
* **`D`**: Same as `d$`.
* **`cc`**: Change (replace) the entire current line.
* **`cw`**: Change from the cursor position to the end of the current word.
* **`[n]cc`**: Change the current line and the next `n-1` lines.
* **`c1G`**: Change from the current line up to line 1.
* **`cG`**: Change from the current line to the last line.
* **`c0`** (zero): Change from the cursor to the beginning of the line (excluding the cursor character).
* **`c^`**: Change from the cursor to the first non-blank character of the line (excluding the cursor character).
* **`c$`**: Change from the cursor to the end of the line (including the cursor character).
* **`c%`**: Change from the character under the cursor (must be a bracket — `(`, `[`, `{`) to its matching closing bracket.
* **`cf<x>`/`c[n]f<x>`**: Change from the cursor up to and including the first/nth occurrence of character `x`.
* **`ct<x>`/`c[n]t<x>`**: Change from the cursor up to (but not including) the first/nth occurrence of character `x`.
* **`c/<word>`**: Change from the cursor up to (but not including) the next occurrence of the search keyword `<word>`.
    * Use `n`/`N` to find the next/previous match; press `.` to repeat the last change.
* **`C`**: Same as `c$`.

**Others:**

* **`J`**: Join the current line with the next line.
* **`x`, `X`**: Delete one character; `x` deletes forward (like `[Del]`), `X` deletes backward (like `[Backspace]`).
* **`[n]x`**: Delete `n` characters forward.
* **`g~`/`gu`/`gU`**: Toggle case/convert to lowercase/convert to uppercase; usually combined with a text object, for example:
    * `guiw`
    * `guw`
* **`<`**: Decrease indentation.
* **`>`**: Increase indentation.
* **`[Ctrl] + a`**: Increment number under cursor by 1.
* **`[Ctrl] + x`**: Decrement number under cursor by 1.
* **`u`**: Undo the last operation.
* **`[Ctrl] + r`**: Redo the last undone operation.
* **`.`**: Repeat the last operation.

## 2.4 Copy & Paste

* **`yy`**: Yank (copy) the entire line where the cursor is located.
* **`[n]yy`**: Yank the current line and the next `n-1` lines (including the current line).
* **`y1G`**: Yank from the current line up to line 1 (including the current line).
* **`yG`**: Yank from the current line to the last line (including the current line).
* **`y0`** (zero): Yank from the cursor position to the beginning of the line (excluding the character under the cursor).
* **`y$`**: Yank from the cursor position to the end of the line (including the character under the cursor).
* **`p`**: Paste the yanked text after the cursor.
* **`P`**: Paste the yanked text before the cursor.

### 2.4.1 Register

**Vim has many registers (these are not CPU registers), including:**

* `0-9`: Vim uses these to store recent copy, delete, and other operations
    * `0`: Stores the most recent copy (yank) content
    * `1-9`: Store the most recent deletes; the latest delete goes into `1`. When a new delete happens, the old `i` register content moves to `i+1`. Since `9` is the max, content in register `9` is discarded.
* `a-zA-Z`: User registers; Vim does not read or write these automatically
* **`"`**: The unnamed register. All delete and copy operations default to this anonymous register.
* `*`: System clipboard register
    * On `Mac`/`Windows`: Same as `+`
    * On `Linux-X11`: Represents the selected mouse region; middle-click pastes on desktop environments
* `+`: System clipboard register
    * On `Mac`/`Windows`: Same as `*`
    * On `Linux-X11`: On desktop, can paste with `Ctrl+V`
* `_`: The "black hole register", similar to `/dev/null` in file systems (discard register)

**How to use these registers: `"<reg name><operator>`**

* The leading `"` is fixed syntax
* `<reg name>`: Register name, e.g., `0`, `a`, `+`, `"` etc.
* `<operator>`: Operation to perform, like `y` (yank), `d` (delete), `p` (paste), etc.
* `q<reg name>q`: Clear the content of a register

**Examples:**

* `:reg`: Show information about all registers
* `:reg <reg name>`: Show the content of a specific register
* `"+yy`: Yank the current line into the system clipboard register
* `"+p`: Paste content from the system clipboard register after the cursor

**How to paste the local system clipboard content into Vim on a remote host via SSH?**

* First, confirm if Vim on the remote host supports `clipboard` by running `vim --version | grep clipboard`. `-clipboard` means no support; `+clipboard` means supported. Clipboard support requires an X environment.
* If the system is CentOS, install a graphical environment like `GNOME`, then install `vim-X11`, and use `vimx` instead of `vim`. Running `vimx --version | grep clipboard` should show clipboard support. Then you can use `vimx` in the SSH terminal to access the remote clipboard.
* To be continued — sharing the clipboard between local and remote machines is not yet solved.

## 2.5 Visual Selection

* **`v`**: Character-wise visual selection; highlights characters as the cursor moves.
* **`vw`**: Select from the cursor position to the end of the current word (if cursor is inside a word, it won't select the entire word).
* **`viw`**: Select the entire word under the cursor (even if the cursor is in the middle of the word).
* **`vi'`**: Select content inside single quotes.
* **`vi"`**: Select content inside double quotes.
* **`vi(`**: Select content inside parentheses.
* **`vi[`**: Select content inside square brackets.
* **`vi{`**: Select content inside curly braces.
* **`V`**: Line-wise visual selection; highlights entire lines as the cursor moves.
    * **`<line number>G`**: Jump to the specified line and visually select all lines in between.
* **`[Ctrl] + v`**: Block-wise visual selection; allows rectangular selection of text.
* **`>`**: Increase indentation.
* **`<`**: Decrease indentation.
* **`~`**: Toggle case.
* **`c/y/d`**: Change/Yank (copy)/Delete.
* **`u`**: Change to lowercase.
* **`U`**: Change to uppercase.
* **`o`**: Jump to the other end of the visual selection.
* **`O`**: Jump to the other end of the visual block.
* **`gv`**: After using `p` or `P` to replace a selection, reselect the replaced area.
* **`gn`**: Select the next search match.
* **`gN`**: Select the previous search match.

## 2.6 Search & Replace

* **Search**
    * **`/[word]`**: Search downward for a string named `word`, supports regular expressions.
    * **`/\<[word]\>`**: Search downward for the exact whole word `word` (word boundary match), supports regular expressions.
    * **`/\V[word]`**: Search downward for the literal string `word` where all characters (except `/`) are treated as normal characters.
    * `?[word]`: Search upward for a string named `word`, supports regular expressions.
    * `?\<[word]\>`: Search upward for the exact whole word `word`, supports regular expressions.
    * **`?\V[word]`**: Search upward for the literal string `word` where all characters (except `?`) are treated as normal characters.
    * `n`: Repeat the previous search in the same direction.
    * `N`: Repeat the previous search in the opposite direction.
    * **`*`**: Search forward for the keyword under the cursor in whole word mode (`\<[word]\>`). The keyword selection rules:
        * Keyword under the cursor
        * The nearest keyword after the cursor on the current line
        * Non-blank string under the cursor
        * The nearest non-blank string after the cursor on the current line
    * **Case sensitivity:**
        * `/[word]\c`: Case insensitive search.
        * `/[word]\C`: Case sensitive search.
    * **`#`**: Like `*`, but searches backward.
    * **`g*`**: Like `*`, but searches for partial matches (non-whole word).
    * **`g#`**: Like `#`, but searches for partial matches.
    * **To search the last visually selected text, follow these steps:**
        1. Enter visual mode
        2. Yank with `y`
        3. Enter search mode with `/`
        4. Insert register content with `[Ctrl] + r`
        5. Enter default register with `"`
* **Replace**
    * **`:[n1],[n2]s/[word1]/[word2]/g`**: Search for `word1` between lines `n1` and `n2` and replace with `word2`, supports regular expressions.
    * **`:[n1],[n2]s/\<[word1]\>/[word2]/g`**: Same as above but with whole word matching.
    * **`:1,$s/[word1]/[word2]/g`** or **`:%s/[word1]/[word2]/g`**: Search and replace `word1` with `word2` from the first to the last line, supports regular expressions.
    * **`:1,$s/[word1]/[word2]/gc`** or **`:%s/[word1]/[word2]/gc`**: Same as above but prompts for confirmation before each replacement.
    * **In visual mode, select a range and enter `:s/[word1]/[word2]/gc` to replace within the selection.**
* **`[Ctrl]+r`** and **`[Ctrl]+w`**: Add the string under the cursor to the search or replace expression.
* **`gn`**: Select the next search match.
* **`gN`**: Select the previous search match.

## 2.7 Record

Record refers to a feature that allows you to record a sequence of keystrokes and save it as a macro for later playback. This is a powerful and versatile feature that can help you automate repetitive tasks, make complex edits more efficiently, and improve your overall productivity when working with text.

**How to Use Vim Record:**

1. **Start Recording**: To start recording a macro, press `q` followed by the register(`a` to `z`) where you want to store the macro. For example, press qa to start recording in register `a`
1. **Perform Actions**: While recording is active, perform the series of commands, edits, or movements you want to include in your macro. Vim will record everything you do.
1. **Stop Recording**: To stop recording, press `q` again. In our example, press `q` once more to stop recording in register `a`
1. **Replay the Macro**: To replay the recorded macro, use the `@` symbol followed by the register where you stored the macro. For example, to replay the `a` register macro, type `@a`

## 2.8 File

* **`:w`**: Save the current file.
* **`:wa`**: Save all files.
* **`:w!`**: Force write to the file if it is read-only; whether it succeeds depends on your file system permissions.
* **`:q`**: Quit Vim.
* **`:q!`**: Quit without saving changes (force quit).
* **`:wq`**: Save and quit; `:wq!` forces save and quit.
* **`:e [filename]`**: Open and edit the specified file.
* **`:e`**: Reload the current file.
* `ZZ`: If the file is unchanged, quit without saving; if changed, save and quit.
* `:w [filename]`: Save the current buffer to a different file (note the space between `w` and filename).
* `:r [filename]`: Read the content of another file and insert it after the cursor line (note the space between `r` and filename).
* `:[n1],[n2]w [filename]`: Write lines `n1` to `n2` to the specified file (space between `w` and filename; space between `[n2]` and `w` optional).
* `vim [filename1] [filename2]...`: Edit multiple files simultaneously.
* `:n`: Edit the next file.
* `:N`: Edit the previous file.
* `:files`: List all files opened by this Vim session.
* `:file`: Show the current file's path.
* **`:Vex`**: Open the directory explorer.

## 2.9 Text Object

**Text objects: Commands like `c`, `d`, `v`, `y`, `g~`, `gu`, `gU` are followed by text objects, generally in the format: `<scope><type>`**

* **Scope: Optional values are `a` and `i`**
    * `a`: Includes the boundaries
    * `i`: Excludes the boundaries
* **Type: Parentheses, braces, brackets, single quotes, double quotes, etc.**
    * `'`
    * `"`
    * `(`/`b`
    * `[`
    * `{`/`B`

**Examples:**

* `i)` : Inside parentheses (excluding the parentheses themselves)
* `a)` : Inside parentheses (including the parentheses)
* `i]` : Inside square brackets (excluding the brackets)
* `a]` : Inside square brackets (including the brackets)
* `i}` : Inside curly braces (excluding the braces)
* `a}` : Inside curly braces (including the braces)
* `i'` : Inside single quotes (excluding the quotes)
* `a'` : Inside single quotes (including the quotes)
* `i"` : Inside double quotes (excluding the quotes)
* `a"` : Inside double quotes (including the quotes)

## 2.10 Text Fold

**According to the folding rules, there are 4 types:**

1. **`manual` (manual folding)**
    * **`:set foldmethod=manual`**
    * **`zf`**: Create a fold, used with a motion or visual range
    * **`zf` can also be combined with text objects, for example:**
        * `zfi{`: Fold the content inside curly braces, excluding the lines with the braces themselves
        * `zfa{`: Fold the content inside curly braces, including the lines with the braces
    * **`zd`/`zD`**: Delete the current fold
    * **`zE`**: Delete all folds
2. **`indent` (indentation-based folding)**
    * **`:set foldmethod=indent`**
    * **`:set foldlevel=[n]`**
3. **`marker` (marker folding)**
    * **`:set foldmethod=marker`**
4. **`syntax` (syntax-based folding)**
    * **`:set foldmethod=syntax`**

**Common operations (uppercase commands are recursive):**

* **`zN`**: Enable folding
* **`zn`**: Disable folding
* **`za`/`zA`**: Toggle fold (fold/unfold) on the current code block
* **`zc`/`zC`**: Close (fold) the current fold
* **`zo`/`zO`**: Open (unfold) the current fold
* **`zm`/`zM`**: Fold all folds
* **`zr`/`zR`**: Open all folds
* **`zj`**: Move to the next fold
* **`zk`**: Move to the previous fold

## 2.11 Buffer

* **`:buffers`**: List all buffers.
* **`:buffer [n]`**: Switch to the specified buffer.
* **`:bnext`**: Switch to the next buffer.
* **`:bprev`**: Switch to the previous buffer.
* **`:edit [filename]`**: Load a file into a new buffer.
* **`:bdelete [n]`**: Delete the specified buffer (if no number given, deletes the current buffer).
* **`:%bdelete`**: Delete all buffers.
    * **`:%bdelete|e#`**: Delete all buffers except the current one; `:e#` reopens the last closed buffer.
* **`:bufdo <cmd>`**: Execute a command on all buffers.
    * **`:bufdo e`**: Reload the files corresponding to all buffers.

## 2.12 Window

* **`[Ctrl] + w + <xxx>`**: Press `[Ctrl]` then `w`, release both, then press `<xxx>`. The following operations are based on this sequence.
* `vim -On file1 file2...` : Vertical split windows.
* `vim -on file1 file2...` : Horizontal split windows.
* `[Ctrl] + w + c` : Close the current window (cannot close the last one).
* `[Ctrl] + w + q` : Close the current window (can close the last one).
* `[Ctrl] + w + o` : Close all other windows except the current one.
* `[Ctrl] + w + s` : Split the current file horizontally.
* `[Ctrl] + w + v` : Split the current file vertically.
* `:sp filename` : Split horizontally and open a new file.
* `:vsp filename` : Split vertically and open a new file.
* **`[Ctrl] + w + l`** : Move the cursor to the window on the right.
* **`[Ctrl] + w + h`** : Move the cursor to the window on the left.
* **`[Ctrl] + w + k`** : Move the cursor to the window above.
* **`[Ctrl] + w + j`** : Move the cursor to the window below.
* **`[Ctrl] + w + w`** : Move the cursor to the next window (toggles between two windows if only two).
* `[Ctrl] + w + L` : Move the current window to the far right.
* `[Ctrl] + w + H` : Move the current window to the far left.
* `[Ctrl] + w + K` : Move the current window to the top.
* `[Ctrl] + w + J` : Move the current window to the bottom.
* `[Ctrl] + w + =` : Make all windows equal height and width.
* `[Ctrl] + w + [+]` : Increase window height by 1.
* `[Ctrl] + w + [n] + [+]` : Increase window height by n.
* `[Ctrl] + w + -` : Decrease window height by 1.
* `[Ctrl] + w + [n] + -` : Decrease window height by n.
* `[Ctrl] + w + >` : Increase window width by 1.
* `[Ctrl] + w + [n] + >` : Increase window width by n.
* `[Ctrl] + w + <` : Decrease window width by 1.
* `[Ctrl] + w + [n] + <` : Decrease window width by n.

## 2.13 Tab

* **`:tabnew [filename]`**: Open a file in a new tab.
    * **`:tabnew %`**: Open the current file in another tab.
* **`:tabedit`**: Same as `tabnew`.
* **`:tabm [n]`**: Move the current tab to position `n` (starting from 0). If `n` is not specified, move to the last position.
* **`gt`/`:tabnext`**: Go to the next tab.
* **`gT`/`:tabprev`**: Go to the previous tab.
* **`:tab sball`**: Open all buffers in tabs.
* **`:tabdo <cmd>`**: Execute a command on all tabs.
    * **`:tabdo e`**: Reload the files corresponding to all tabs.

## 2.14 Quickfix

* `:copen`：Open the quickfix window (view compile, grep, etc. information).
* `:copen 10`：Open the quickfix window with a height of 10.
* `:cclose`：Close the quickfix window.
* `:cfirst`：Jump to the first error in quickfix.
* `:clast`：Jump to the last error in quickfix.
* `:cc [nr]`：View error number `[nr]`.
* `:cnext`：Jump to the next error in quickfix.
* `:cprev`：Jump to the previous error in quickfix.
* `:set modifiable`：Make quickfix writable, allowing deletion of entries using commands like `dd`.

## 2.15 Terminal

**Vim can embed a terminal**

* `:terminal` : Open the terminal.
* `[Ctrl] + \ + [Ctrl] + n` : Exit terminal mode.

## 2.16 Mapping

* **`map`**: Recursive mapping  
* **`noremap`**: Non-recursive mapping  
* **`unmap`**: Reset specified key to default behavior  
* `mapclear`: Clear all `map` configurations, use with caution  

| COMMANDS | MODES |
|:--|:--|
| `map`、`noremap`、`unmap` | Normal, Visual, Select, Operator-pending |
| `nmap`、`nnoremap`、`nunmap` | Normal |
| `vmap`、`vnoremap`、`vunmap` | Visual and Select |
| `smap`、`snoremap`、`sunmap` | Select |
| `xmap`、`xnoremap`、`xunmap` | Visual |
| `omap`、`onoremap`、`ounmap` | Operator-pending |
| `map!`、`noremap!`、`unmap!` | Insert and Command-line |
| `imap`、`inoremap`、`iunmap` | Insert |
| `lmap`、`lnoremap`、`lunmap` | Insert, Command-line, Lang-Arg |
| `cmap`、`cnoremap`、`cunmap` | Command-line |
| `tmap`、`tnoremap`、`tunmap` | Terminal-Job |

**View all `map` commands:**

* `:map`
    * `:map <c-l>`
    * `:map <f5>`
    * `:map \rn`
* `:noremap`
* `:nnoremap`

**Redirect all `map` commands to a file:**

1. `:redir! > vim_keys.txt`
1. `:silent verbose map`
1. `:redir END`

**Special parameters:**

* `<buffer>`: The mapping applies only to the current buffer.
* `<nowait>`
* `<silent>`: Disable showing mapping messages.
* `<special>`
* `<script>`
* `<expr>`
* `<unique>`

## 2.17 Key Representation

* **`<f-num>`**: For example, `<f1>`, `<f2>`.
* **`<c-key>`**: Represents `[Ctrl]` plus another key.
* **`<a-key>`/`<m-key>`**: Represents `[Alt]` plus another key.
* **On Mac, there is no `<p-key>` for `[Option]`. Instead, the actual output character produced by pressing `[Option]` plus another key is used as the mapping key, for example:**
    * `[Option] + a`: `å`

## 2.18 Config

* **`:set <config>?`**: View the value of `<config>`.
    * `verbose set <config>?`: Shows the source of the configuration.
    * `:set filetype?`: View the file type.
* **`:echo &<config>`**: Also view the value of `<config>`.
    * `:echo &filetype`: View the file type.
* **`set <config> += <value>`**: Add to a setting; multiple items can be added separated by commas.
* **`set <config> -= <value>`**: Remove from a setting; only one item can be removed at a time.

### 2.18.1 Frequently-used Configs

```vim
:set nocompatible                   " Set to be incompatible with original vi mode (must be set at the very beginning)
:set backspace=indent,eol,start     " Set BS (Backspace) key behavior
:set softtabstop=4                  " Number of spaces a <BS> deletes while in insert mode; recommended to set to 4
:set shiftwidth=4                   " Width of auto-indents; usually same as softtabstop
:set autoindent                     " Enable automatic indentation
:set tabstop=4                      " Width of a Tab character; default is 8, recommended to set to 4
:set expandtab                      " Use spaces instead of tabs for indentation
:set noexpandtab                    " Use tabs instead of spaces for indentation
:set winaltkeys=no                  " Enable normal ALT key capture in GVim
:set nowrap                         " Disable line wrapping
:set ttimeout                       " Enable terminal key code timeout (special keys send sequences starting with ESC)
:set ttm=100                        " Set terminal key code timeout to 100 milliseconds
:set term=?                         " Set terminal type, e.g., xterm
:set ignorecase                     " Ignore case in search (can be shortened to :set ic)
:set noignorecase                   " Don't ignore case in search (can be shortened to :set noic)
:set smartcase                      " Smart case: ignore case unless search pattern includes uppercase
:set list                           " Show invisible characters
:set nolist                         " Hide invisible characters
:set listchars?                     " Show current list of invisible characters
:set number                         " Show line numbers; use :set nonumber to disable
:set relativenumber                 " Show relative line numbers (distance from current line)
:set paste                          " Enter paste mode (disable auto indent and such during paste)
:set wrap                           " Enable line wrapping
:set nowrap                         " Disable line wrapping
:set nopaste                        " Exit paste mode
:set spell                          " Enable spell checking
:set hlsearch                       " Highlight search results
:set nohlsearch                     " Disable search highlighting
:set ruler                          " Always show cursor position
:set guicursor                      " Set GUI cursor shape
:set incsearch                      " Show search matches incrementally while typing
:set insertmode                     " Always stay in insert mode; use [Ctrl] + o for temporary commands
:set all                            " List all current settings
:set cursorcolumn                   " Highlight current column
:set cursorline                     " Highlight current line
:set fileencoding                   " Show current file encoding
:set showtabline=0/1/2              " 0: never show tabline; 1: show when multiple tabs; 2: always show tabline
:syntax on                          " Enable syntax highlighting
:syntax off                         " Disable syntax highlighting
```

### 2.18.2 Debugging Configs

1. `runtimepath` (`rtp)`: Specifies the directory paths Vim will use to search for runtime files.
1. `path`: Sets the list of directories to be searched when using commands like :find.
1. `packpath`: Determines where Vim looks for packages.
1. `backupdir` (`bdir)`: Specifies the directory for backup files.
1. `directory` (`dir)`: Indicates where swap files are stored.
1. `spellfile`: Defines the file locations for spell checking.
1. `undodir`: Designates the directory for undo files.
1. `viewdir`: Specifies the directory for saved views.
1. `backupskip`: Lists patterns for files that should not have backups.
1. `wildignore`: Sets the patterns to be ignored during file name completion.
1. `suffixes`: Defines suffixes that are less important during filename matching.
1. `helpfile`: Specifies the location of the help file.
1. `tags`: Lists the tag files used for tag commands.

### 2.18.3 Config File

Vim actively records your past actions so that you can easily continue your work next time. The file that stores these records is `~/.viminfo`.

Global Vim settings are generally placed in `/etc/vimrc` (or `/etc/vim/vimrc`). It is not recommended to modify this file directly. Instead, you can modify your personal configuration file `~/.vimrc` (which does not exist by default and must be created manually).

**When running Vim, if you modify the contents of `~/.vimrc`, you can reload it immediately by executing `:source ~/.vimrc` or `:so %` to apply the new configurations.**

## 2.19 Variable

Neovim supports several types of variables:

* **Global Variables `(g:)`**: These are accessible from anywhere in your Neovim configuration and during your Neovim sessions. They are often used to configure plugins and Neovim settings.
* **Buffer Variables `(b:)`**: These are specific to the current buffer (file) you are working on. Changing the buffer will change the scope and access to these variables.
* **Window Variables `(w:)`**: These are specific to the current window. Neovim allows multiple windows to be open, each can have its own set of w: variables.
* **Tab Variables `(t:)`**: These are associated with a specific tab in your Neovim environment.
* **Vim Variables `(v:)`**: These are built-in variables provided by Neovim that contain information about the environment, such as v:version for the Neovim version or v:count for the last used count for a command.

**Setting Variables:**

```vim
let g:my_variable = "Hello, Neovim!"
let b:my_buffer_variable = 42
let w:my_window_variable = [1, 2, 3]
let t:my_tab_variable = {'key': 'value'}
```

**Accessing Variables:**

```vim
:echo g:my_variable
:echo b:my_buffer_variable
:echo w:my_window_variable
:echo t:my_tab_variable
```

**Unsetting Variables:**

```vim
:unlet g:my_variable
```

## 2.20 Help Doc

* `:help CTRL-W`: View help for `ctrl + w` in normal mode.
* `:help i_CTRL-V`: View help for `ctrl + v` in insert mode (`i_` means insert mode).
* `:help v_CTRL-A`: View help for `ctrl + a` in visual mode (`v_` means visual mode).
* `:help :s`: View help for the `:s` command.

**Documentation path:** `/usr/share/vim/vim82/doc`

* `/usr/share/vim/vim82/doc/help.txt`: Main documentation file.

**`vimtutor`**: Provides a simple tutorial.

## 2.21 Troubleshooting

1. `vim -V10logfile.txt`
1. `echo &runtimepath`

## 2.22 Assorted

* **`echo`**
    * **`:echom xxx`**: The message will be saved in the message history, which can be viewed with `:message`.
* **Command history**
    * **`q:`**: Enter command-line history editing.
    * **`q/`**: Enter search history editing.
    * **`q[a-z`]`**: Press `q` followed by any letter to enter command history.
    * You can edit a command like editing a buffer, then press Enter to execute it.
    * Press `[Ctrl] + c` to exit history editing and return to the editing buffer; however, the history editing window remains open, allowing you to refer to previous commands and input your own.
    * **Type `:x` to close history editing and discard changes, returning to the editing buffer.**
    * Pressing Enter on an empty command also exits history editing and returns to the editing buffer.
* **`[Ctrl] + g`**: Show file statistics.
* **`g + [Ctrl] + g`**: Show byte statistics.

### 2.22.1 Symbol Index

* **`[Ctrl] + ]`**: Jump to the definition of the symbol under the cursor.
* **`gf`**: Jump to the header file under the cursor.
    * Use `set path=` or `set path+=` to set or add header file search paths.
    * Use `set path?` to view the current value of this variable.
* **`[Ctrl] + ^`**: Switch between the two most recently edited files.

### 2.22.2 Insert Form Feed(tab)

Referring to [How can I insert a real tab character in Vim?](https://stackoverflow.com/questions/6951672/how-can-i-insert-a-real-tab-character-in-vim), after setting parameters like `tabstop`, `softtabstop`, and `expandtab`, the `tab` key will be replaced by spaces. If you want to insert a literal `\t` character, you can press `[Ctrl] + v + i` in insert mode, where:

* `[Ctrl] + v` means to input the literal character.
* `i` represents the `\t` character.

### 2.22.3 Multiply-line Editing

**Example: Insert the same content on multiple lines simultaneously**

1. At the column where you need to insert content, press `[Ctrl] + v` and select the lines to modify simultaneously  
1. Press `I` to enter insert mode  
1. Type the text you want to insert  
1. Press `esc` twice  

**Example: Insert the same content at the end of multiple lines simultaneously**

1. At the column where you need to insert content, press `[Ctrl] + v` and select the lines to modify simultaneously  
1. Press `$` to move to the end of the line  
1. Press `A` to enter insert mode  
1. Type the text you want to insert  
1. Press `esc` twice  

**Example: Delete the same content on multiple lines simultaneously**

1. At the column where you need to delete content, press `[Ctrl] + v` and select the lines to modify simultaneously  
1. Select the columns to delete simultaneously  
1. Press `d` to delete simultaneously  

### 2.22.4 中文乱码

**Edit `/etc/vimrc` and append the following content**

```sh
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
```

### 2.22.5 Project Customized Config

The same `~/.vimrc` cannot be used for all projects. Different projects may require some specialized configuration options. You can use the following setup method.

```vim
if filereadable("./.workspace.vim")
    source ./.workspace.vim
endif
```

# 3 Plugin

## 3.1 Overview

### 3.1.1 Plugin Manager

#### 3.1.1.1 vim-plug

Home: [vim-plug](https://github.com/junegunn/vim-plug)

**Install:**

```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

**Usage:**

* Config
    ```vim
    call plug#begin()

    " List your plugins here
    Plug 'tpope/vim-sensible'

    call plug#end()
    ```

* `:PlugStatus`
* `:PlugInstall`
* `:PlugClean`

**Update source(`~/.vim/autoload/plug.vim`):**

```vim
" Change
let fmt = get(g:, 'plug_url_format', 'https://git::@github.com/%s.git')
" To
let fmt = get(g:, 'plug_url_format', 'https://git::@mirror.ghproxy.com/https://github.com/%s.git')

" Change
\ '^https://git::@github\.com', 'https://github.com', '')
" To
\ '^https://git::@mirror\.ghproxy\.com/https://github\.com', 'https://mirror.ghproxy.com/https://github.com', '')
```

**How to install plugins from different sources:**

* Option 1: Specify the full URL of the plugin. For example, change `Plug 'morhetz/gruvbox'` to `Plug 'https://github.com/morhetz/gruvbox'`.
* Option 2: Disable `URI` validation. By default, `Plug` does not allow plugins from different sources. To disable this feature, modify `~/.vim/autoload/plug.vim` as follows:
    ```vim
    " Delete following code snippet
                elsif !compare_git_uri(current_uri, uri)
                    [false, ["Invalid URI: #{current_uri}",
                            "Expected:    #{uri}",
                            "PlugClean required."].join($/)]
    " Delete following code snippet
        elseif !s:compare_git_uri(remote, a:spec.uri)
        let err = join(['Invalid URI: '.remote,
                        \ 'Expected:    '.a:spec.uri,
                        \ 'PlugClean required.'], "\n")
    ```

##### 3.1.1.1.1 Tips

1. `echo g:plug_home`: show home dir.

#### 3.1.1.2 packer.nvim

Home: [packer.nvim](https://github.com/wbthomason/packer.nvim)

**Install:**

```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

**Configuration:**

* `~/.config/nvim/init.vim`
    ```vim
    if has('nvim')
        lua require('packer-plugins')
    endif
    ```

* `~/.config/nvim/lua/packer-plugins.lua`
    ```lua
    vim.cmd [[packadd packer.nvim]]

    return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Your plugins
    end)
    ```

**Usage:**

* `PackerCompile`: You must run this or `PackerSync` whenever you make changes to your plugin configuration. Regenerate compiled loader file.
* `PackerClean`: Remove any disabled or unused plugins.
* `PackerInstall`: Clean, then install missing plugins.
* `PackerStatus`: Show list of installed plugins.

## 3.2 Prepare

**为什么需要准备环境，vim的插件管理不是会为我们安装插件么？因为某些复杂插件，比如`ycm`是需要手动编译的，而编译就会依赖一些编译相关的工具，并且要求的版本比较高**

**由于我用的系统是`CentOS 7.9`，通过`yum install`安装的工具都过于陈旧，包括`gcc`、`g++`、`clang`、`clang++`、`cmake`等等，这些工具都需要通过其他方式重新安装**

### 3.2.1 vim8 (Required)

上述很多插件对vim的版本有要求，至少是`vim8`，而一般通过`yum install`安装的vim版本是`7.x`

```sh
# 卸载
yum remove vim-* -y

# 通过非官方源fedora安装最新版的vim
curl -L https://copr.fedorainfracloud.org/coprs/lantw44/vim-latest/repo/epel-7/lantw44-vim-latest-epel-7.repo -o /etc/yum.repos.d/lantw44-vim-latest-epel-7.repo
yum install -y vim

# 确认
vim --version | head -1
```

### 3.2.2 Symbol-ctags (Recommend)

Home: [ctags](https://ctags.io/)

**`ctags`的全称是`universal-ctags`**

**安装：参照[github官网文档](https://github.com/universal-ctags/ctags)进行编译安装即可**

```sh
git clone https://github.com/universal-ctags/ctags.git --depth 1
cd ctags

# 安装依赖工具
yum install -y autoconf automake

./autogen.sh
./configure --prefix=/usr/local
make
make install # may require extra privileges depending on where to install
```

**`ctags`参数：**

* `--c++-kinds=+px`：`ctags`记录c++文件中的函数声明，各种外部和前向声明
* `--fields=+ailnSz`：`ctags`要求描述的信息，其中：
    * `a`：如果元素是类成员的话，要标明其调用权限(即public或者private)
    * `i`：如果有继承，则标明父类
    * `l`：标明标记源文件的语言
    * `n`：标明行号
    * `S`：标明函数的签名（即函数原型或者参数列表）
    * `z`：标明`kind`
* `--extras=+q`：强制要求ctags做如下操作，如果某个语法元素是类的一个成员，ctags默认会给其记录一行，以要求ctags对同一个语法元素再记一行，这样可以保证在VIM中多个同名函数可以通过路径不同来区分
* `-R`：`ctags`递归生成子目录的tags（在项目的根目录下很有意义）

**在工程中生成`ctags`：**

```sh
# 与上面的~/.vimrc中的配置对应，需要将tag文件名指定为.tags
ctags --c++-kinds=+px --fields=+ailnSz --extras=+q -R -f .tags *
```

**如何为`C/C++`标准库生成`ctags`，这里生成的标准库对应的`ctags`文件是`~/.vim/.cfamily_systags`**

```sh
mkdir -p ~/.vim
# 下面2种选一个即可

# 1. 通过yum install -y gcc安装的gcc是4.8.5版本
ctags --c++-kinds=+px --fields=+ailnSz --extras=+q -R -f ~/.vim/.cfamily_systags \
/usr/include \
/usr/local/include \
/usr/lib/gcc/x86_64-redhat-linux/4.8.5/include/ \
/usr/include/c++/4.8.5/

# 2. 通过上面编译安装的gcc是10.3.0版本
ctags --c++-kinds=+px --fields=+ailnSz --extras=+q -R -f ~/.vim/.cfamily_systags \
/usr/include \
/usr/local/include \
/usr/local/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include \
/usr/local/include/c++/10.3.0
```

**如何为`Python`标准库生成`ctags`，这里生成的标准库对应的`ctags`文件是`~/.vim/.python_systags`（[ctags, vim and python code](https://stackoverflow.com/questions/47948545/ctags-vim-and-python-code)）**

```sh
ctags --languages=python --python-kinds=-iv --fields=+ailnSz --extras=+q -R -f ~/.vim/.python_systags /usr/lib64/python3.6
```

**Usage:**

* `[Ctrl] + ]`：跳转到符号定义处。如果有多条匹配项，则会跳转到第一个匹配项
* `[Ctrl] + w + ]`：在新的窗口中跳转到符号定义处。如果有多条匹配项，则会跳转到第一个匹配项
* `:ts`：显示所有的匹配项。按`ECS`再输入序号，再按`Enter`就可以进入指定的匹配项
* `:tn`：跳转到下一个匹配项
* `:tp`：跳转到上一个匹配项
* `g + ]`：如果有多条匹配项，会直接显式（同`:ts`）

**Configuration(`~/.vimrc`):**

* **注意，这里将tag的文件名从`tags`换成了`.tags`，这样避免污染项目中的其他文件。因此在使用`ctags`命令生成tag文件时，需要通过`-f .tags`参数指定文件名**
* **`./.tags;`表示在文件所在目录下查找名字为`.tags`的符号文件，`;`表示查找不到的话，向上递归到父目录，直到找到`.tags`或者根目录**
* **`.tags`是指在vim的当前目录（在vim中执行`:pwd`）下查找`.tags`文件**

```vim
" tags search mode
set tags=./.tags;,.tags
" c/c++ standard library ctags
set tags+=~/.vim/.cfamily_systags
" python standard library ctags
set tags+=~/.vim/.python_systags
```

### 3.2.3 Symbol-cscope (Optional)

Home: [cscope](http://cscope.sourceforge.net/)

**相比于`ctags`，`cscope`支持更多功能，包括查找定义、查找引用等等。但是该项目最近一次更新是2012年，因此不推荐使用。推荐使用`gtags`**

**Install:**

```sh
wget -O cscope-15.9.tar.gz 'https://sourceforge.net/projects/cscope/files/latest/download' --no-check-certificate
tar -zxvf cscope-15.9.tar.gz
cd cscope-15.9

./configure
make
sudo make install
```

**如何使用命令行工具：**

```sh
# 创建索引，该命令会在当前目录生成一个名为cscope.out索引文件
# -R: 在生成索引文件时，搜索子目录树中的代码
# -b: 只生成索引文件，不进入cscope的界面
# -k: 在生成索引文件时，不搜索/usr/include目录
# -q: 生成cscope.in.out和cscope.po.out文件，加快cscope的索引速度
# -i: 指定namefile
# -f: 可以指定索引文件的路径
cscope -Rbkq

# 查找符号，执行下面的命令可以进入一个交互式的查询界面
cscope
```

**如何在vim中使用**

```vim
" 添加数据库
:cscope add cscope.out

" 查找定义
:cscope find g <symbol>

" 查找引用
:cscope find s <symbol>

" 启用 quickfix
" +: 将结果追加到 quickfix 中
" -: 清除 quickfix 中的内容，并将结果添加到 quickfix 中
:set cscopequickfix=s-,c-,d-,i-,t-,e-,a-

" 其他配置方式以及使用方式参考help
:help cscope
```

**Configuration(`~/.vimrc`):**

```vim
" 启用 quickfix
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-

" 最后面的 :copen<cr> 表示打开 quickfix
nnoremap <leader>sd :cscope find g <c-r><c-w><cr>:copen<cr>
nnoremap <leader>sr :cscope find s <c-r><c-w><cr>:copen<cr>
nnoremap <leader>sa :cscope find a <c-r><c-w><cr>:copen<cr>
nnoremap <leader>st :cscope find t <c-r><c-w><cr>:copen<cr>
nnoremap <leader>se :cscope find e <c-r><c-w><cr>:copen<cr>
nnoremap <leader>sf :cscope find f <c-r>=expand("<cfile>")<cr><cr>:copen<cr>
nnoremap <leader>si :cscope find i <c-r>=expand("<cfile>")<cr><cr>:copen<cr>
```

**注意事项：**

* 尽量在源码目录创建数据库，否则cscope默认会扫描所有文件，效率很低

### 3.2.4 Symbol-gtags (Optional)

Home: [gtags](https://www.gnu.org/software/global/global.html)

**`gtags`的全称是`GNU Global source code tagging system`**

**这里有个坑，上面安装的是`gcc-10.3.0`，这个版本编译安装`global`源码会报错（[dev-util/global-6.6.4 : fails to build with -fno-common or gcc-10](https://bugs.gentoo.org/706890)），错误信息大概是`global.o:(.bss+0x74): first defined here`，因此，我们需要再安装一个低版本的gcc，并且用这个低版本的gcc来编译`global`**

```sh
# 安装源
yum install -y centos-release-scl scl-utils

# 安装gcc 7
yum install -y devtoolset-7-toolchain

# 切换软件环境（本小节剩余的操作都需要在这个环境中执行，如果不小心退出来的话，可以再执行一遍重新进入该环境）
scl enable devtoolset-7 bash
```

**[gtags下载地址](https://ftp.gnu.org/pub/gnu/global/)**

```sh
# 安装相关软件
yum install -y ncurses-devel gperf bison flex libtool libtool-ltdl-devel texinfo

wget https://ftp.gnu.org/pub/gnu/global/global-6.6.7.tar.gz --no-check-certificate
tar -zxvf global-6.6.7.tar.gz
cd global-6.6.7

# 检测脚本，缺什么就装什么
sh reconf.sh

# 编译安装
./configure
make
sudo make install

# 安装成功后，在目录 /usr/local/share/gtags 中会有 gtags.vim 以及 gtags-cscope.vim 这两个文件
# 将这两个文件拷贝到 ~/.vim 目录中
cp -vrf /usr/local/share/gtags/gtags.vim /usr/local/share/gtags/gtags-cscope.vim ~/.vim
```

**如何使用命令行工具：**

```sh
# 把头文件也当成源文件进行解析，否则可能识别不到头文件中的符号
export GTAGSFORCECPP=1

# 在当前目录构建数据库，会在当前目录生成如下三个文件
# 1. GTAGS: 存储符号定义的数据库
# 2. GRTAGS: 存储符号引用的数据库
# 3. GPATH: 存储路径的数据库
gtags

# 查找定义
global -d <symbol>

# 查找引用
global -r <symbol>
```

**Configuration(`~/.vimrc`):**

1. 第一个`GTAGSLABEL`告诉`gtags`默认`C/C++/Java`等六种原生支持的代码直接使用`gtags`本地分析器，而其他语言使用`pygments`模块
1. 第二个环境变量必须设置（在我的环境里，不设置也能work），否则会找不到`native-pygments`和`language map`的定义

```vim
" Setting native-pygments causes "gutentags: gtags-cscope job failed, returned: 1", so I changed it to native
" let $GTAGSLABEL = 'native-pygments'
let $GTAGSLABEL = 'native'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
if filereadable(expand('~/.vim/gtags.vim'))
    source ~/.vim/gtags.vim
endif
if filereadable(expand('~/.vim/gtags-cscope.vim'))
    source ~/.vim/gtags-cscope.vim
endif
```

**`FAQ`：**

1. `global -d`找不到类定义，可能原因包括
    1. **final修饰的类，`gtags`找不到其定义，坑爹的bug，害我折腾了很久**
1. `global -d`无法查找成员变量的定义

### 3.2.5 LSP-clangd (Recommend)

**`clangd`是`LSP, Language Server Protocol`的一种实现，主要用于`C/C++/Objective-C`等语言**

### 3.2.6 LSP-ccls (Optional)

**`ccls`是`LSP, Language Server Protocol`的一种实现，主要用于`C/C++/Objective-C`等语言**

**安装：参照[github官网文档](https://github.com/MaskRay/ccls)进行编译安装即可**

```sh
git clone https://mirror.ghproxy.com/https://github.com/MaskRay/ccls.git
cd ccls

function setup_github_repo() {
    gitmodules=( $(find . -name '.gitmodules' -type f) )
    for gitmodule in ${gitmodules[@]}
    do
        echo "setup github repo for '${gitmodule}'"
        sed -i -r 's|([^/]?)https://github.com/|\1https://mirror.ghproxy.com/https://github.com/|g' ${gitmodule}
    done
}
# 初始化子模块
setup_github_repo
git submodule init && git submodule update

# 其中 CMAKE_PREFIX_PATH 用于指定 clang/llvm 相关头文件和lib的搜索路径，按照「安装llvm」小节中的安装方法，安装路径就是 /usr/local
cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local

# 编译
cmake --build Release

# 安装
cmake --build Release --target install
```

**如何为工程生成全量索引？**

1. 通过`cmake`等构建工具生成`compile_commands.json`，并将该文件至于工程根目录下
1. 配置`LSP-client`插件，我用的是`LanguageClient-neovim`
1. vim打开工程，便开始自动创建索引

### 3.2.7 LSP-jdtls (Optional)

**`jdtls`是`LSP, Language Server Protocol`的一种实现，主要用于`Java`语言**

**安装：参照[github官网文档](https://github.com/eclipse/eclipse.jdt.ls)进行编译安装即可**

```sh
git clone https://github.com/eclipse/eclipse.jdt.ls.git --depth 1
cd eclipse.jdt.ls

# 要求java 11及以上的版本
JAVA_HOME=/path/to/java/11 ./mvnw clean verify
```

**安装后的配置文件以及二进制都在`./org.eclipse.jdt.ls.product/target/repository`目录中**

* 运行日志默认在config目录中，例如`./org.eclipse.jdt.ls.product/target/repository/config_linux/`目录下

## 3.3 Color Scheme

### 3.3.1 gruvbox

Home: [gruvbox](https://github.com/morhetz/gruvbox)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'morhetz/gruvbox'

" Enable the gruvbox color scheme (the corresponding .vim file needs to be in the ~/.vim/colors directory)
colorscheme gruvbox
" Set background, possible values are: dark, light
set background=dark
" Set contrast, possible values are: soft, medium, hard. There is a configuration item for dark and light themes respectively.
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'

call plug#end()
```

**Install:**

```sh
# ~/.vim/colors not exist by default
mkdir ~/.vim/colors
cp ~/.vim/plugged/gruvbox/colors/gruvbox.vim ~/.vim/colors/
```

### 3.3.2 solarized

Home: [solarized](https://github.com/altercation/vim-colors-solarized)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'altercation/vim-colors-solarized'

" Enable the solarized color scheme (the corresponding .vim file needs to be in the ~/.vim/colors directory)
colorscheme solarized
" Set background, possible values are: dark, light
set background=dark

call plug#end()
```

**Install:**

```sh
# ~/.vim/colors not exist by default
mkdir ~/.vim/colors
cp ~/.vim/plugged/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/
```

### 3.3.3 catppuccin

Home: [catppuccin/nvim](https://github.com/catppuccin/nvim)

**Configuration(`~/.config/nvim/lua/packer-plugins.lua`):**

```lua
use { "catppuccin/nvim", as = "catppuccin" }
vim.cmd.colorscheme "catppuccin-frappe" -- catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
```

### 3.3.4 Trending Neovim Colorschemes

[Trending Neovim Colorschemes](https://dotfyle.com/neovim/colorscheme/trending)

## 3.4 Dashboard

[Suggest me some startup screen plugins](https://www.reddit.com/r/neovim/comments/138t41q/suggest_me_some_startup_screen_plugins/)

### 3.4.1 dashboard-nvim

Home: [dashboard-nvim](https://github.com/nvimdev/dashboard-nvim)

**Configuration(`~/.config/nvim/lua/packer-plugins.lua`):**

```lua
use {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
        require('dashboard').setup {
            -- config
        }
    end,
    requires = {'nvim-tree/nvim-web-devicons'}
}
```

**FAQ:**

* It has compatible issue with LeaderF, every time use LeaderF, the bottom line go up by one line.

### 3.4.2 alpha-nvim

Home: [alpha-nvim](https://github.com/goolord/alpha-nvim)

**Configuration(`~/.config/nvim/lua/packer-plugins.lua`):**

```lua
use {
    'goolord/alpha-nvim',
    requires = { 'echasnovski/mini.icons' },
    config = function ()
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
}
```

## 3.5 vim-airline

Home: [vim-airline](https://github.com/vim-airline/vim-airline)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'vim-airline/vim-airline'

call plug#end()
```

## 3.6 lazy.nvim tools

### 3.6.1 noice.nvim

Home: [noice.nvim](https://github.com/folke/noice.nvim)

**Configuration(`~/.config/nvim/lua/packer-plugins.lua`):**

```lua
use {
    'folke/noice.nvim',
    requires = {
        'MunifTanjim/nui.nvim',  -- Required dependency for UI components
        'rcarriga/nvim-notify',  -- Optional for enhanced notifications
    },
    config = function()
        require("noice").setup({
            cmdline = {
                enabled = true,
                view = "cmdline"
            },
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false, -- add a border to hover docs and signature help
            },
        })
    end
}
```

### 3.6.2 which-key

Home: [which-key](https://github.com/folke/which-key.nvim)

**Configuration(`~/.config/nvim/lua/packer-plugins.lua`):**

```lua
use {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        require("which-key").setup({
            triggers = {} -- No automatic triggering
        })

        -- Keymap binding for buffer local keymaps
        vim.api.nvim_set_keymap('n', '<leader>?',
            [[<cmd>lua require('which-key').show({ global = false })<CR>]],
            { noremap = true, silent = true, desc = "Buffer Local Keymaps (which-key)" }
        )
    end
}
```

## 3.7 indentLine

Home: [indentLine](https://github.com/Yggdroot/indentLine)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'Yggdroot/indentLine'

let g:indentLine_noConcealCursor = 1
let g:indentLine_color_term = 239
let g:indentLine_char = '|'

call plug#end()
```

## 3.8 Highlighting

### 3.8.1 nvim-treesitter

Home: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

**Configuration(`~/.config/nvim/lua/packer-plugins.lua`):**

```lua
use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
}
require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true
    }
}
```

**Usage:**

* `:TSInstall <language_to_install>`
* `:TSInstallInfo`

### 3.8.2 vim-cpp-enhanced-highlight

Home: [vim-cpp-enhanced-highlight](https://github.com/octol/vim-cpp-enhanced-highlight)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'octol/vim-cpp-enhanced-highlight'

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_concepts_highlight = 1

call plug#end()
```

## 3.9 coc.nvim

Home: [coc.nvim](https://github.com/neoclide/coc.nvim)

**This plugin serves as an `LSP Client` and can support multiple different `LSP Servers`.**

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Set default to on or off, 1 means on (default), 0 means off
" let g:coc_start_at_startup = 0

" In insert mode, map <tab> to move to the next completion item when auto-completion is triggered
inoremap <silent><expr> <tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<tab>" :
      \ coc#refresh()
inoremap <expr><s-tab> coc#pum#visible() ? coc#pum#prev(1) : "\<c-h>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" In insert mode, map <cr> to select the current completion item
inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<c-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"

" K to view documentation
nnoremap <silent> K :call <SID>show_documentation()<cr>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Inlay hint, only works for neovim >= 0.10.0
nmap <leader>rh :CocCommand document.toggleInlayHint<cr>

" Diagnostic shortcuts
nmap <c-k> <Plug>(coc-diagnostic-prev)
nmap <c-j> <Plug>(coc-diagnostic-next)
nmap <leader>rf <Plug>(coc-fix-current)

" Automatically perform semantic range selection
" [Option] + s, which is 「ß」
" [Option] + b, which is 「∫」
vmap ß <Plug>(coc-range-select)
vmap ∫ <Plug>(coc-range-select-backward)

" Code navigation mappings
nmap <leader>rd <Plug>(coc-definition)
nmap <leader>ry <Plug>(coc-type-definition)
nmap <leader>ri <Plug>(coc-implementation)
nmap <leader>rr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

" CodeAction
nmap <leader>ac <Plug>(coc-codeaction-cursor)

" CocList related mappings
" [Shift] + [Option] + j, means 「Ô」
" [Shift] + [Option] + k, means 「」
nnoremap <silent> <leader>cr :CocListResume<cr>
nnoremap <silent> <leader>ck :CocList -I symbols<cr>
nnoremap <silent> Ô :CocNext<cr>
nnoremap <silent>  :CocPrev<cr>

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

call plug#end()
```

**Usage:**

* **`:CocStart`：若在配置中取消了自启动，则需要手动开启**
* **`:CocUpdate`：更新所有插件**
* **`:CocConfig`：编辑配置文件，其路径为`~/.vim/coc-settings.json`**
* **`:CocAction`：代码生成**
* **`:CocInfo`**
* **`:CocList [options] [args]`**
    * `:CocList extensions`
    * Operation
        * 编辑模式
            * `[Ctrl] + o`：切换到一般模式
        * 一般模式
            * `i/I/o/O/a/A`：进入编辑模式
            * `p`：开启或关闭预览窗口
            * `[Ctrl] + e`：向下滚动预览窗口中的内容
            * `[Ctrl] + y`：向上滚动预览窗口中的内容
* **`:CocCommand <插件命令>`**
    * `:CocCommand workspace.showOutput`：查看日志

**Paths:**

* `~/.config/coc/extensions`：插件目录

**Help Doc(`:help coc-nvim`):**

* `:help coc-inlayHint`

**FAQ:**

* `client coc abnormal exit with: 1`：大概率是`node`有问题
* `node`版本别太新也别太旧，`v16`比较好
* `clangd`版本16以上，支持展开宏定义（`K`）
* 如何修改头文件搜索路径？在`compile_commands.json`或`compile_flags.txt`中通过`-I`参数指定即可
* 索引文件路径：`<project path>/.cache/clangd`
* 在`cmake`中设置`set(CMAKE_CXX_STANDARD 17)`，其生成的`compile_commands.json`中包含的编译命令不会包含`-std=gnu++17`参数，于是`clangd`在处理代码中用到的`c++17`新特性时会报`warning`（例如`Decomposition declarations are a C++17 extension (clang -Wc++17-extensions)`）。通过设置`CMAKE_CXX_FLAGS`，加上编译参数`-std=gnu++17`可以解决该问题
    * 仅仅设置`CMAKE_CXX_STANDARD`是不够的，还需要设置`CMAKE_CXX_STANDARD_REQUIRED`，参考[CMake's set(CMAKE_CXX_STANDARD 11) does not work](https://github.com/OSGeo/PROJ/issues/1924)
* 在`cmake`中设置`set(CMAKE_CXX_COMPILER g++)`也不会对`clangd`起作用，例如`clang`没有`-fopt-info-vec`这个参数，仍然会`warning`
* `clangd`使用的标准库搜索路径：由编译器决定，即`compile_commands.json`中编译命令所使用的编译器决定。如果这个编译器是个低版本的，那么就会用低版本对应的头文件路径，高版本则对应高版本头文件路径

### 3.9.1 coc-explorer

Home: [coc-explorer](https://github.com/weirongxu/coc-explorer)

**Install:**

* `:CocInstall coc-explorer`

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

" ... Omit common coc.nvim configs
" Map opening file explorer to shortcut [Space] + e
nmap <space>e <cmd>CocCommand explorer<cr>

call plug#end()
```

**Usage:**

* `?`：帮助文档
* `j`：下移光标
* `k`：上移光标
* `h`：收起目录
* `l`：展开目录或打开文件
* `gh`：递归收起（全部收起）
* `gl`：递归展开（全部展开)
* `*`：选择/取消选择
* `J`：选择/取消选择，并下移光标
* `K`：选择/取消选择，并上移光标
* `Il`：启用/关闭文件`label`预览
* `Ic`：启用/关闭文件内容预览
* `q`：退出
* `a`：新建文件
* `A`：新建目录
* `r`：重命名
* `df/dF`：删除文件，`df`放入回收站，`dF`永久删除
* **Symbols:**
    * `?`：新文件，尚未纳入`git`
    * `A`：新文件，已加入暂存区
    * `M`：文件已修改
        * `dim`：文件与上一个提交不一致
        * `bright`：文件与暂存区不一致
* **Assorted:**
    * 文件前面的数字是错误数量，可以通过`Il`查看查看完整的label

### 3.9.2 coc-java

Home: [coc-java](https://github.com/search?q=coc-java)

**`Java`语言的`LSP-Server`的实现是[jdt.ls](https://github.com/eclipse/eclipse.jdt.ls)。而`coc-java`是`coc.nvim`的扩展，对`jdt.ls`进行进一步的封装**

**Install:**

* `:CocInstall coc-java`
* 安装路径：`~/.config/coc/extensions/node_modules/coc-java`
* 数据路径：`~/.config/coc/extensions/coc-java-data`

**Configuration(`:CocConfig`)**

```json
{
    "java.enabled": true,
    "java.format.enable": false,
    "java.maven.downloadSources": true,
    "java.saveActions.organizeImports": false,
    "java.compile.nullAnalysis.mode": "automatic",
    "java.trace.server": "verbose",
    "java.home": "/usr/lib/jvm/java-17-oracle",
    "java.debug.vimspector.profile": null
}
```

**Usage:**

* `:CocCommand workspace.showOutput java`：查看`jdt.ls`日志
    * `"java.trace.server": "verbose"`：更详细的日志
* `:CocCommand java.open.serverLog`：查看`jdt.ls`原始日志

**Tips：**

* 若项目用到了`thrift`或者`protobuf`这些会创建源码的三方库。需要将这部分源码以及源码编译生成的`.class`文件打包成`.jar`文件，然后通过配置，告知`jdt.ls`
    * 通过配置`java.project.referencedLibraries`，传入额外的jar路径。该配置好像无法起作用。[Doesn't recognize imports in classpath on a simple project](https://github.com/neoclide/coc-java/issues/93)提到将`vim`换成`neovim`可以解决，其他相关的`issue`如下：
        * [java.project.referencedLibraries](https://github.com/redhat-developer/vscode-java/pull/1196#issuecomment-568192224)
        * [Add multiple folders to src path](https://github.com/microsoft/vscode-java-dependency/issues/412)
        * [Managing Java Projects in VS Code](https://code.visualstudio.com/docs/java/java-project)
        * [referencedLibraries / classpath additions not working](https://github.com/neoclide/coc-java/issues/146)
    * 通过配置`.classpath`，参考配置[eclipse.jdt.ls/org.eclipse.jdt.ls.core/.classpath](https://github.com/eclipse/eclipse.jdt.ls/blob/master/org.eclipse.jdt.ls.core/.classpath)
        ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        <classpath>
            <classpathentry kind="lib" path="xxx.jar" sourcepath="xxx-source"/>
        </classpath>
        ```

        * 假设子模块用到了`thrift`，那么需要在子模块的目录下放置`.classpath`，而不是在工程根目录放置`.classpath`
* 有插件`org.eclipse.m2e:lifecycle-mapping`的时候，`jdt.ls`没法正常工作，目前暂未解决

### 3.9.3 coc-pyright

Home: [coc-pyright](https://github.com/fannheyward/coc-pyright)

**Install:**

* `:CocInstall coc-pyright`

**Configuration(`:CocConfig`)**

* `python.analysis.typeCheckingMode`：禁用`reportGeneralTypeIssues`等错误信息。python是动态类型的语言，静态类型推导的错误信息可以忽略

```json
{
    "python.analysis.typeCheckingMode": "off"
}
```

**Tips：**

* 用pip安装的三方库，pyright找不到
    * 可以使用[venv](https://www.liaoxuefeng.com/wiki/1016959663602400/1019273143120480)模块来构建隔离的python环境，步骤如下（`coc-pyright`官网）
    ```sh
    python3 -m venv ~/.venv
    source ~/.venv/bin/activate
    <install modules with pip and work with Pyright>
    deactivate
    ```

* 格式化import
    * `CocCommand pyright.organizeimports`

### 3.9.4 coc-rust-analyzer

Home: [coc-rust-analyzer](https://github.com/fannheyward/coc-rust-analyzer)

**Install:**

* `:CocInstall coc-rust-analyzer`
* 确保`rust-analyzer`已经正常安装：`rustup component add rust-analyzer`

### 3.9.5 coc-snippets

Home: [coc-snippets](https://github.com/neoclide/coc-snippets)

**`coc-snippets`用于提供片段扩展功能（类似于`IDEA`中的`sout`、`psvm`、`.var`等等）**

**Install:**

* `:CocInstall coc-snippets`
* 安装路径：`~/.config/coc/extensions/node_modules/coc-snippets`

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

" 省略公共配置
" 将 触发代码片段扩展 映射到快捷键 [Ctrl] + l
imap <c-e> <Plug>(coc-snippets-expand)
" 在 visual 模式下，将 跳转到下一个占位符 映射到快捷键 [Ctrl] + j
vmap <c-j> <Plug>(coc-snippets-select)
" 在编辑模式下，将 跳转到下一个/上一个占位符 分别映射到 [Ctrl] + j 和 [Ctrl] + k
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'

call plug#end()
```

**Usage:**

* 在编辑模式下，输入片段后，按`<c-e>`触发片段扩展
* `:CocList snippets`：查看所有可用的`snippet`

**FAQ:**

* 最新版本无法跳转到`fori`的类型占位符，转而使用另一个插件`UltiSnips`

#### 3.9.5.1 vim-snippets

Home: [vim-snippets](https://github.com/honza/vim-snippets)

`vim-snippets`插件提供了一系列`snippet`的定义

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'honza/vim-snippets'

call plug#end()
```

**使用：与`coc-snippets`自带`snippet`的用法一致**

### 3.9.6 coc-settings.json

[All config keys](https://github.com/neoclide/coc.nvim/blob/master/doc/coc-config.txt)

```json
{
    "languageserver": {
        "clangd": {
            "command": "clangd",
            "args": ["--log=verbose", "--all-scopes-completion", "--query-driver=g++"],
            "rootPatterns": ["compile_flags.txt", "compile_commands.json"],
            "filetypes": ["c", "cc", "cpp", "c++", "objc", "objcpp", "tpp"]
        }
    },
    "coc.preferences.diagnostic.displayByAle": false,
    "diagnostic.virtualText": true,
    "diagnostic.virtualTextPrefix": "◉ ",
    "diagnostic.virtualTextCurrentLineOnly": false,
    "explorer.file.reveal.auto": true,
    "suggest.noselect": true,
    "inlayHint.display": false,
    "snippets.ultisnips.pythonPrompt": false,
    "java.enabled": true,
    "java.format.enable": false,
    "java.maven.downloadSources": true,
    "java.saveActions.organizeImports": false,
    "java.compile.nullAnalysis.mode": "automatic",
    "java.trace.server": "verbose",
    "java.home": "/usr/lib/jvm/java-17-oracle",
    "java.debug.vimspector.profile": null,
    "python.formatting.enabled": false,
    "pyright.reportGeneralTypeIssues": false,
    "python.analysis.typeCheckingMode": "off"
}
```

* `coc.preferences.diagnostic.displayByAle`：是否以`ALE`插件的模式进行显示
* `diagnostic.virtualText`：是否显式诊断信息
* `diagnostic.virtualTextPrefix`：诊断信息的前缀
* `diagnostic.virtualTextCurrentLineOnly`：是否只显示光标所在行的诊断信息
* `explorer.file.reveal.auto`：使用在文件管理器中高亮当前`buffer`的所对应的文件
* `suggest.noselect`：`true/false`，表示自动补全时，是否自动选中第一个。默认为`false`，即自动选中第一个，如果再按`tab`则会跳转到第二个。[Ability to tab to first option](https://github.com/neoclide/coc.nvim/issues/1339)
* `inlayHint.display`：是否默认显示`inlayHint`

## 3.10 vimspector

Home: [vimspector](https://github.com/puremourning/vimspector)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'puremourning/vimspector'

let g:vimspector_variables_display_mode = 'full'

nnoremap <leader>vl :call vimspector#Launch()<cr>
nnoremap <leader>vb :call vimspector#ToggleBreakpoint()<cr>
nnoremap <leader>vc :call vimspector#ClearBreakpoints()<cr>
nnoremap <leader>vt :call vimspector#JumpToProgramCounter()<cr>
nnoremap <leader>vu :call vimspector#UpFrame()<cr>
nnoremap <leader>vd :call vimspector#DownFrame()<cr>
nnoremap <leader>vr :call vimspector#Reset()<cr>

nnoremap <f4> :call vimspector#Stop()<cr>
nnoremap <f5> :call vimspector#Restart()<cr>
nnoremap <f6> :call vimspector#Continue()<cr>
nnoremap <f18> :call vimspector#RunToCursor()<cr> " f18 can be achieved through shift + F6
nnoremap <f7> :call vimspector#StepInto()<cr>
nnoremap <f8> :call vimspector#StepOver()<cr>
nnoremap <f20> :call vimspector#StepOut()<cr> " f20 can be achieved through shift + F8

call plug#end()
```

**Usage:**

* **页面布局**
    * `Variables and scopes`：左上角。回车用于展开和收起
    * `Watches`：左中。进入编辑模式，输入表达式按回车可新增`Watch`；删除键可删除`Watch`
    * `StackTrace`：左下角。按回车可展开线程堆栈
    * `Console`：标准输出，标准错误
* **对于每个项目，我们都需要在项目的根目录提供一个`.vimspector.json`，来配置项目相关的`debug`参数**
    * `configurations.<config_name>.default: true`，是否默认使用该配置。如果有多个配置项的话，不要设置这个
    * `C-Family`示例：
        ```json
        {
            "configurations": {
                "C-Family Launch": {
                    "adapter": {
                        "extends": "vscode-cpptools",
                        "sync_timeout": 100000,
                        "async_timeout": 100000
                    },
                    "filetypes": ["cpp", "c", "objc", "rust"],
                    "configuration": {
                        "request": "launch",
                        "program": "<absolute path to binary>",
                        "args": [],
                        "cwd": "<absolute working directory>",
                        "environment": [],
                        "externalConsole": true,
                        "MIMode": "gdb"
                    }
                },
                "C-Family Attach": {
                    "adapter": {
                        "extends": "vscode-cpptools",
                        "sync_timeout": 100000,
                        "async_timeout": 100000
                    },
                    "filetypes": ["cpp", "c", "objc", "rust"],
                    "configuration": {
                        "request": "attach",
                        "program": "<absolute path to binary>",
                        "MIMode": "gdb"
                    }
                }
            }
        }
        ```

### 3.10.1 coc-java-debug

Home: [coc-java-debug](https://github.com/dansomething/coc-java-debug)

`coc-java-debug`依赖`coc.nvim`、`coc-java`以及`vimspector`

* 通过`coc.nvim`来安装、卸载插件，其接口通过`CocCommand`对外露出
* `coc-java-debug`是`vimspector`的`adapter`

**安装：进入vim界面后执行`:CocInstall coc-java-debug`即可**

**Usage:**

* **`:CocCommand java.debug.vimspector.start`**
* **对于每个项目，我们都需要在项目的根目录提供一个`.vimspector.json`，来配置项目相关的`debug`参数**
    * `adapters.java-debug-server.port`：是`java-debug-server`启动时需要占用的端口号，这里填占位符，在启动时会自动为其分配一个可用的端口号
    * `configurations.<config_name>.configuration.port`：对应`Java`程序的`debug`端口号
    * `configurations.<config_name>.configuration.projectName`：对应`pom.xml`的项目名称。[Debugging Java with JDB or Vim](https://urfoex.blogspot.com/2020/08/debugging-java-with-jdb-or-vim.html)。如果这个参数对不上的话，那么在`Watches`页面添加`Watch`时，会报如下的错误
        * 未设置该参数时：`Result: Cannot evaluate because of java.lang.IllegalStateException: Cannot evaluate, please specify projectName in launch.json`
        * 填写错误的项目名称时：`Result: Cannot evaluate because of java.lang.IllegalStateException: Project <wrong name> cannot be found`
        * [Visual Studio Code projectName](https://stackoverflow.com/questions/48490671/visual-studio-code-projectname)
        * [Debugger for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-debug)
    ```json
    {
        "adapters": {
            "java-debug-server": {
                "name": "vscode-java",
                "port": "${AdapterPort}"
            }
        },
        "configurations": {
            "Java Attach": {
                "adapter": {
                    "extends": "java-debug-server",
                    "sync_timeout": 100000,
                    "async_timeout": 100000
                },
                "configuration": {
                    "request": "attach",
                    "host": "127.0.0.1",
                    "port": "5005",
                    "projectName": "${projectName}"
                },
                "breakpoints": {
                    "exception": {
                        "caught": "N",
                        "uncaught": "N"
                    }
                }
            }
        }
    }
    ```

## 3.11 Copilot.vim

Home: [Copilot.vim](https://github.com/github/copilot.vim)

[Getting started with GitHub Copilot](https://docs.github.com/en/copilot/getting-started-with-github-copilot?tool=neovim)

`OpenAI`加持的自动补全，可以根据函数名补全实现

**版本要求：**

* `Neovim`
* `Vim >= 9.0.0185`

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

if has('nvim')
    Plug 'github/copilot.vim'

    " Map trigger snippet expansion to shortcut [Option] + p, which is 「π」
    inoremap <script><expr> π copilot#Accept("\<cr>")
    let g:copilot_no_tab_map = v:true
    " Map jump to next suggestion to shortcut [Option] + ], which is 「‘」
    inoremap ‘ <Plug>(copilot-next)
    " Map jump to previous suggestion to shortcut [Option] + [, which is 「“」
    inoremap “ <Plug>(copilot-previous)
    " Map enable snippet suggestions to shortcut [Option] + \, which is 「«」
    inoremap « <Plug>(copilot-suggest)
endif

call plug#end()
```

**Usage:**

* Login & Enable
    ```vim
    :Copilot setup
    :Copilot enable
    ```

* `:help copilot`

## 3.12 textobj-user

Home: [textobj-user](https://github.com/kana/vim-textobj-user)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

" The kana/vim-textobj-user provides the basic ability to customize text objects, other plugins are extensions based on it
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'

" Change the symbol for the parameter text object, the default is a comma
let g:vim_textobj_parameter_mapping = 'a'

call plug#end()
```

**Usage:**

* **`ia/aa`：参数对象。可以用`via/vaa`/`dia/daa`/`cia/caa`来选中/删除/改写当前参数**
* **`ii/ai`：缩进对象。可以用`vii/vai`/`dii/dai`/`cii/cai`来选中/删除/改写同一缩进层次的内容**
* **`if/af`：函数对象。可以用`vif/vaf`/`dif/daf`/`cif/caf`来选中/删除/改写当前函数的内容**

## 3.13 LeaderF

Home: [LeaderF](https://github.com/Yggdroot/LeaderF)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" Map fuzzy file search to shortcut [Ctrl] + p
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_ShortcutB = '<m-n>'
" Map :LeaderfMru to shortcut [Ctrl] + n
nnoremap <c-n> :LeaderfMru<cr>
" Map :LeaderfFunction! to shortcut [Option] + p, which is 「π」
nnoremap π :LeaderfFunction!<cr>
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_JumpToExistingWindow = 0
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

call plug#end()
```

* 依赖`ctags`

**Usage:**

1. `:LeaderfFunction!`：弹出函数列表
1. `:LeaderfMru`：查找最近访问的文件，通过上面的配置映射到快捷键`[Ctrl] + n`
1. 通过上面的配置，将文件模糊搜索映射到快捷键`[Ctrl] + p`
* 搜索模式，输入即可进行模糊搜索
    * `tab`：切换到普通模式，普通模式下，可以通过`j/k`上下移动
    * `<c-r>`：在`fuzzy search mode`以及`regex mode`之间进行切换
    * `<c-f>`：在`full path search mode`以及`name only search mode`之间进行切换
    * `<c-u>`：清空搜索内容
    * `<c-j>/<c-k>`：上下移动
    * `<c-a>`：选中所有
    * `<c-l>`：清除选中
    * `<c-s>`：选中当前文件
    * `<c-t>`：在新的`tab`中打开选中的文件
    * `<c-p>`：预览
1. 不起作用，可能是`python`的问题
    * `:checkhealth`

## 3.14 fzf.vim

Home: [fzf.vim](https://github.com/junegunn/fzf.vim)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Map :Ag and :Rg to \ag and \rg respectively
nnoremap <leader>ag :Ag<cr>
nnoremap <leader>rg :Rg<cr>
" Configure shortcuts [Ctrl] + a, [Ctrl] + q, to import results into quickfix
" https://github.com/junegunn/fzf.vim/issues/185
function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
endfunction
let g:fzf_action = { 'ctrl-q': function('s:build_quickfix_list') }
" '--preview-window=up:80%:wrap' explanation:
"   'up': This places the preview window above the main fzf selection list.
"   '80%': This sets the height of the preview window to 80% lines.
"   'wrap': This enables line wrapping in the preview window, so if the content is wider than the window, it will wrap to the next line instead of being truncated.
" '--bind ctrl-a:select-all' explanation:
"   '--bind': This is the option used to define key bindings in fzf.
"   'ctrl-a': This specifies the key combination that will activate the binding. In this case, it's the "Control" key combined with the "a" key.
"   'select-all': This is the action that will be taken when the key binding is activated. In this case, it selects all items in the list.
let $FZF_DEFAULT_OPTS = '--preview-window=up:80%:wrap --bind ctrl-a:select-all'
" Exclude entries that match only filenames in :Ag and :Rg search results
" https://github.com/junegunn/fzf.vim/issues/346
" --smart-case means case insensitive, removing this parameter makes it case sensitive
" g:rg_customized_options allows adding some custom parameters, such as --glob '!pattern' to exclude certain search paths
let g:rg_customized_options = ""
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".g:rg_customized_options." ".shellescape(<q-args>), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

call plug#end()
```

* 安装会额外执行`~/.vim/plugged/fzf/install`这个脚本，来下载`fzf`的二进制，如果长时间下载不下来的话，可以改成代理地址后（在脚本中搜索`github`关键词，加上`https://mirror.ghproxy.com/`前缀），再手动执行脚本进行下载安装

**用法（搜索相关的语法可以参考[junegunn/fzf-search-syntax](https://github.com/junegunn/fzf#search-syntax)）：**

1. `:Ag`：进行全局搜索（依赖命令行工具`ag`，安装方式参考该插件[github主页](https://github.com/ggreer/the_silver_searcher)）
1. `:Rg`：进行全局搜索（依赖命令行工具`rg`，安装方式参考该插件[github主页](https://github.com/BurntSushi/ripgrep)）
* `[Ctrl] + j/k`/`[Ctrl] + n/p`：以行为单位上下移动
* `PageUp/PageDown`：以页为单位上下移动
* **匹配规则**
    * **`xxx`：模糊匹配（可能被分词）**
    * **`'xxx`：非模糊匹配（不会被分词）**
    * **`^xxx`：前缀匹配**
    * **`xxx$`：后缀匹配**
    * **`!xxx`：反向匹配**
    * **上述规则均可自由组合**
    * **如何精确匹配一个包含空格的字符串：`'Hello\ world`。由于常规的空格被用作分词符，因此空格前要用`\`进行转义**

## 3.15 Git Plugins

### 3.15.1 vim-fugitive

Home: [vim-fugitive](https://github.com/tpope/vim-fugitive)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'tpope/vim-fugitive'

call plug#end()
```

**Usage:**

* `:Git`：作为`git`的替代，后跟`git`命令行工具的正常参数即可

### 3.15.2 diffview.nvim

Home: [diffview.nvim](https://github.com/sindrets/diffview.nvim)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'sindrets/diffview.nvim'

call plug#end()
```

**Usage:**

* `:DiffviewOpen`
* `:DiffviewOpen HEAD~2`
* `:DiffviewOpen <commit>`

## 3.16 nerdcommenter

Home: [nerdcommenter](https://github.com/preservim/nerdcommenter)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'preservim/nerdcommenter'

let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

call plug#end()
```

**Usage:**

* **`\cc`：添加注释，对每一行都会添加注释**
* **`\cm`：对被选区域用一对注释符进行注释**
* **`\cs`：添加性感的注释**
* **`\ca`：更换注释的方式**
* **`\cu`：取消注释**
* **`\c<space>`：如果被选区域有部分被注释，则对被选区域执行取消注释操作，其它情况执行反转注释操作**

## 3.17 vim-codefmt

Home: [vim-codefmt](https://github.com/google/vim-codefmt)

**支持各种格式化工具：**

* `C-Family`：`clang-format`
* `CSS`/`Sass`/`SCSS`/`Less`：`js-beautify`
* `JSON`：`js-beautify`
* `HTML`：`js-beautify`
* `Go`：`gofmt`
* `Java`：`google-java-format`/`clang-format`
* `Python`：`Autopep8`/`Black`/`YAPF`
    * Combine `isort` to reorder imports.
    * `pip install autopep8 isort`
* `Shell`：`shfmt`

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

" Map :FormatCode to shortcut [Ctrl] + l
nnoremap <c-l> :FormatCode<cr>
xnoremap <c-l> :FormatLines<cr>

let g:codefmt_python_formatter = "custom"
let g:codefmt_custom_python = {
  \ 'exe': 'bash',
  \ 'args': ['-c', 'isort --quiet - && autopep8 -'],
  \ }

call plug#end()

" ......................
" .Put after plug#end().
" ......................

call glaive#Install()
" Set the startup command for google-java-format, where
" sudo wget -O /usr/local/share/google-java-format-1.22.0-all-deps.jar 'https://github.com/google/google-java-format/releases/download/v1.22.0/google-java-format-1.22.0-all-deps.jar'
" sudo ln -s /usr/local/share/google-java-format-1.22.0-all-deps.jar /usr/local/share/google-java-format-all-deps.jar
" --aosp uses the AOSP style with 4 spaces for indentation
Glaive codefmt google_java_executable="java -jar /usr/local/share/google-java-format-all-deps.jar --aosp"
```

**Usage:**

* `:FormatCode`：格式化
* `:Glaive codefmt`：查看配置（也可以通过`:help codefmt`查看所有配置项）
    * `clang_format_executable`: `clang_format`可执行文件路径，可以通过`Glaive codefmt clang_format_executable="clang-format-10"`进行修改

**安装`Python`的格式化工具`autopep8`**

```sh
pip install --upgrade autopep8

# 创建软连接（下面是我的安装路径，改成你自己的就行）
sudo chmod a+x /home/home/liuyehcf/.local/lib/python3.6/site-packages/autopep8.py
sudo ln /home/home/liuyehcf/.local/lib/python3.6/site-packages/autopep8.py /usr/local/bin/autopep8
```

**安装`Perl`的格式化工具`perltidy`**

* `cpan install Perl::Tidy`
* `brew install perltidy`
* `perltidy`相关的`pull request`尚未合入，需要自行合入，[Add perl formatting support using Perltidy](https://github.com/google/vim-codefmt/pull/227)，步骤如下：
    ```sh
    git fetch origin pull/227/head:pull_request_227
    git rebase pull_request_227
    ```

    * 或者，如果不想这么做，可以用如下方式暂时代替：
        ```
        " 配置 perl 的格式化，需要用 gg=G 进行格式化
        " https://superuser.com/questions/805695/autoformat-for-perl-in-vim
        " 通过 cpan Perl::Tidy 安装 perltidy
        autocmd FileType perl setlocal equalprg=perltidy\ -st\ -ce
        if has('nvim')
            autocmd FileType perl nnoremap <silent><buffer> <c-l> gg=G<c-o>
        else
            autocmd FileType perl nnoremap <silent><buffer> <c-l> gg=G<c-o><c-o>
        endif
        ```
**安装`json`的格式化工具`js-beauty`**

* `npm -g install js-beautify`

## 3.18 vim-surround

Home: [vim-surround](https://github.com/tpope/vim-surround)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'tpope/vim-surround'

call plug#end()
```

**Usage:**

* 完整用法参考`:help surround`
* `cs`：`cs, change surroundings`，用于替换当前文本的环绕符号
    * `cs([`
    * `cs[{`
    * `cs{<q>`
    * `cs{>`
* `ds`：`ds, delete surroundings`，用于删除当前文本的环绕符号
    * `ds{`
    * `ds<`
    * `ds<q>`
* `ys`：`you surround`，用于给指定文本加上环绕符号。文本指定通常需要配合文本对象一起使用
    * `ysiw[`：`iw`是文本对象
    * `ysa"fprint`：其中`a"`是文本对象，`f`表示用函数调用的方式环绕起来，`print`是函数名。形式为`print(<text>)`
    * `ysa"Fprint`：类似`ysa"fprint`，`F`表示会在参数列表前后多加额外的空格。形式为`print( <text> )`
    * `ysa"<c-f>print`：类似`ysa"fprint`，`<c-f>`表示环绕符号加到最外侧。形式为`(print <text>)`
* `yss`：给当前行加上环绕符号（不包含`leading whitespace`和`trailing whitespace`）
    * `yss(`
    * `yssb`
    * `yss{`
    * `yssB`
* `yS`：类似`ys`，但会在选中文本的前一行和后一行加上环绕符号
    * `ySiw[`：`iw`是文本对象
* `ySS`：类似`yes`，但会在选中文本的前一行和后一行加上环绕符号
    * `ySS(`
    * `ySSb`
    * `ySS{`
    * `ySSB`
* `[visual]S`：用于给`visual mode`选中的文本加上环绕符号
    * `vllllS'`：其中，`v`表示进入`visual`模式，`llll`表示向右移动4个字符
    * `vllllSfprint`：其中，`v`表示进入`visual`模式，`llll`表示向右移动4个字符，`f`表示用函数调用的方式环绕起来，`print`是函数名。形式为`print(<text>)`
    * `vllllSFprint`：类似`vllllSfprint`，`F`表示会在参数列表前后多加额外的空格。形式为`print( <text> )`
    * `vllllS<c-f>print`：类似`vllllSfprint`，`<c-f>`表示环绕符号加到最外侧。形式为`(print <text>)`

## 3.19 UltiSnips

Home: [UltiSnips](https://github.com/SirVer/ultisnips)

UltiSnips is the ultimate solution for snippets in Vim.

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plug 'honza/vim-snippets'

" Trigger configuration.
let g:UltiSnipsExpandTrigger = "<c-e>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"

call plug#end()
```

## 3.20 vim-wordmotion

Home: [vim-wordmotion](https://github.com/chaoren/vim-wordmotion)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'chaoren/vim-wordmotion'

let g:wordmotion_nomap = 1 " Disable by default
nnoremap <leader>w :let g:wordmotion_nomap = !g:wordmotion_nomap \| call wordmotion#reload()<CR>

call plug#end()
```

## 3.21 Complete Configuration

### 3.21.1 `~/.vimrc` or `~/.config/nvim/init.vim`

```vim
" Load extra config (pre step)
if filereadable(expand("~/.vimrc_extra_pre"))
    source ~/.vimrc_extra_pre
endif

call plug#begin()
" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'vim-airline/vim-airline'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'Yggdroot/indentLine'

let g:indentLine_noConcealCursor = 1
let g:indentLine_color_term = 239
let g:indentLine_char = '|'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Set default to on or off, 1 means on (default), 0 means off
" let g:coc_start_at_startup = 0

" In insert mode, map <tab> to move to the next completion item when auto-completion is triggered
inoremap <silent><expr> <tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<tab>" :
      \ coc#refresh()
inoremap <expr><s-tab> coc#pum#visible() ? coc#pum#prev(1) : "\<c-h>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" In insert mode, map <cr> to select the current completion item
inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<c-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"

" K to view documentation
nnoremap <silent> K :call <SID>show_documentation()<cr>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Inlay hint, only works for neovim >= 0.10.0
nmap <leader>rh :CocCommand document.toggleInlayHint<cr>

" Diagnostic shortcuts
nmap <c-k> <Plug>(coc-diagnostic-prev)
nmap <c-j> <Plug>(coc-diagnostic-next)
nmap <leader>rf <Plug>(coc-fix-current)

" Automatically perform semantic range selection
" [Option] + s, which is 「ß」
" [Option] + b, which is 「∫」
vmap ß <Plug>(coc-range-select)
vmap ∫ <Plug>(coc-range-select-backward)

" Code navigation mappings
nmap <leader>rd <Plug>(coc-definition)
nmap <leader>ry <Plug>(coc-type-definition)
nmap <leader>ri <Plug>(coc-implementation)
nmap <leader>rr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

" CodeAction
nmap <leader>ac <Plug>(coc-codeaction-cursor)

" CocList related mappings
" [Shift] + [Option] + j, means 「Ô」
" [Shift] + [Option] + k, means 「」
nnoremap <silent> <leader>cr :CocListResume<cr>
nnoremap <silent> <leader>ck :CocList -I symbols<cr>
nnoremap <silent> Ô :CocNext<cr>
nnoremap <silent>  :CocPrev<cr>

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Map opening file explorer to shortcut [Space] + e
nmap <space>e <cmd>CocCommand explorer<cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if has('nvim')
    Plug 'github/copilot.vim'

    " Map trigger snippet expansion to shortcut [Option] + p, which is 「π」
    inoremap <script><expr> π copilot#Accept("\<cr>")
    let g:copilot_no_tab_map = v:true
    " Map jump to next suggestion to shortcut [Option] + ], which is 「‘」
    inoremap ‘ <Plug>(copilot-next)
    " Map jump to previous suggestion to shortcut [Option] + [, which is 「“」
    inoremap “ <Plug>(copilot-previous)
    " Map enable snippet suggestions to shortcut [Option] + \, which is 「«」
    inoremap « <Plug>(copilot-suggest)
endif

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'puremourning/vimspector'

let g:vimspector_variables_display_mode = 'full'

nnoremap <leader>vl :call vimspector#Launch()<cr>
nnoremap <leader>vb :call vimspector#ToggleBreakpoint()<cr>
nnoremap <leader>vc :call vimspector#ClearBreakpoints()<cr>
nnoremap <leader>vt :call vimspector#JumpToProgramCounter()<cr>
nnoremap <leader>vu :call vimspector#UpFrame()<cr>
nnoremap <leader>vd :call vimspector#DownFrame()<cr>
nnoremap <leader>vr :call vimspector#Reset()<cr>

nnoremap <f4> :call vimspector#Stop()<cr>
nnoremap <f5> :call vimspector#Restart()<cr>
nnoremap <f6> :call vimspector#Continue()<cr>
nnoremap <f18> :call vimspector#RunToCursor()<cr> " f18 can be achieved through shift + F6
nnoremap <f7> :call vimspector#StepInto()<cr>
nnoremap <f8> :call vimspector#StepOver()<cr>
nnoremap <f20> :call vimspector#StepOut()<cr> " f20 can be achieved through shift + F8

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

" The kana/vim-textobj-user provides the basic ability to customize text objects, other plugins are extensions based on it
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'

" Change the symbol for the parameter text object, the default is a comma
let g:vim_textobj_parameter_mapping = 'a'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" Map fuzzy file search to shortcut [Ctrl] + p
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_ShortcutB = '<m-n>'
" Map :LeaderfMru to shortcut [Ctrl] + n
nnoremap <c-n> :LeaderfMru<cr>
" Map :LeaderfFunction! to shortcut [Option] + p, which is 「π」
nnoremap π :LeaderfFunction!<cr>
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_JumpToExistingWindow = 0
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Map :Ag and :Rg to \ag and \rg respectively
nnoremap <leader>ag :Ag<cr>
nnoremap <leader>rg :Rg<cr>
" Configure shortcuts [Ctrl] + a, [Ctrl] + q, to import results into quickfix
" https://github.com/junegunn/fzf.vim/issues/185
function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
endfunction
let g:fzf_action = { 'ctrl-q': function('s:build_quickfix_list') }
" '--preview-window=up:80%:wrap' explanation:
"   'up': This places the preview window above the main fzf selection list.
"   '80%': This sets the height of the preview window to 80% lines.
"   'wrap': This enables line wrapping in the preview window, so if the content is wider than the window, it will wrap to the next line instead of being truncated.
" '--bind ctrl-a:select-all' explanation:
"   '--bind': This is the option used to define key bindings in fzf.
"   'ctrl-a': This specifies the key combination that will activate the binding. In this case, it's the "Control" key combined with the "a" key.
"   'select-all': This is the action that will be taken when the key binding is activated. In this case, it selects all items in the list.
let $FZF_DEFAULT_OPTS = '--preview-window=up:80%:wrap --bind ctrl-a:select-all'
" Exclude entries that match only filenames in :Ag and :Rg search results
" https://github.com/junegunn/fzf.vim/issues/346
" --smart-case means case insensitive, removing this parameter makes it case sensitive
" g:rg_customized_options allows adding some custom parameters, such as --glob '!pattern' to exclude certain search paths
let g:rg_customized_options = ""
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".g:rg_customized_options." ".shellescape(<q-args>), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'tpope/vim-fugitive'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'sindrets/diffview.nvim'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'preservim/nerdcommenter'

let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

" Map :FormatCode to shortcut [Ctrl] + l
nnoremap <c-l> :FormatCode<cr>
xnoremap <c-l> :FormatLines<cr>

let g:codefmt_python_formatter = "custom"
let g:codefmt_custom_python = {
  \ 'exe': 'bash',
  \ 'args': ['-c', 'isort --quiet - && autopep8 -'],
  \ }

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'tpope/vim-surround'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plug 'honza/vim-snippets'

" Trigger configuration.
let g:UltiSnipsExpandTrigger = "<c-e>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'chaoren/vim-wordmotion'

let g:wordmotion_nomap = 1 " Disable by default
nnoremap <leader>w :let g:wordmotion_nomap = !g:wordmotion_nomap \| call wordmotion#reload()<CR>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
call plug#end()

" Extra config for vim-codefmt
call glaive#Install()
" Set the startup command for google-java-format, where
" sudo wget -O /usr/local/share/google-java-format-1.22.0-all-deps.jar 'https://github.com/google/google-java-format/releases/download/v1.22.0/google-java-format-1.22.0-all-deps.jar'
" sudo ln -s /usr/local/share/google-java-format-1.22.0-all-deps.jar /usr/local/share/google-java-format-all-deps.jar
" --aosp uses the AOSP style with 4 spaces for indentation
Glaive codefmt google_java_executable="java -jar /usr/local/share/google-java-format-all-deps.jar --aosp"

if has('nvim')
    lua require('packer-plugins')
endif

" ctags configuration
" tags search mode
set tags=./.tags;,.tags
" c/c++ standard library ctags
set tags+=~/.vim/.cfamily_systags
" python standard library ctags
set tags+=~/.vim/.python_systags

" gtags configuration
" Setting native-pygments causes "gutentags: gtags-cscope job failed, returned: 1", so I changed it to native
" let $GTAGSLABEL = 'native-pygments'
let $GTAGSLABEL = 'native'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
if filereadable(expand('~/.vim/gtags.vim'))
    source ~/.vim/gtags.vim
endif
if filereadable(expand('~/.vim/gtags-cscope.vim'))
    source ~/.vim/gtags-cscope.vim
endif

" Treat files with the .tpp extension as cpp files so that plugins for cpp can take effect on .tpp files
autocmd BufRead,BufNewFile *.tpp set filetype=cpp

" Configuration for specific file types
" Do not hide double quotes in JSON files, equivalent to set conceallevel=0
let g:vim_json_conceal = 0

" Return to last edit position when opening files (You want this!), https://stackoverflow.com/questions/7894330/preserve-last-editing-position-in-vim
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Reset registers
function! Clean_up_registers()
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
endfunction
noremap <silent> <leader>rc :call Clean_up_registers()<cr>

" Insert mode, cursor movement shortcuts
" [Option] + h, which is「˙」
" [Option] + j, which is「∆」
" [Option] + k, which is「˚」
" [Option] + l, which is「¬」
inoremap ˙ <c-o>h
inoremap ∆ <c-o>j
inoremap ˚ <c-o>k
inoremap ¬ <c-o>l
inoremap <c-w> <c-o>w
" inoremap <c-e> <c-o>e
inoremap <c-b> <c-o>b
inoremap <c-x> <c-o>x

" Map "replace" to [Option] + r, which is 「®」
" <c-r><c-w> means [Ctrl] + r and [Ctrl] + w, used to fill the word under the cursor into the search/replace field
nnoremap ® :%s/<c-r><c-w>

" When pasting in Visual mode, by default, the deleted content is placed in the default register
" gv reselects the replaced area
" y places the selected content into the default register
xnoremap p pgvy

" Select the current line
nnoremap <leader>sl ^vg_
" Select the whole buffer
nnoremap <leader>va ggVG

" Cancel search highlight by default when pressing Enter
nnoremap <cr> :nohlsearch<cr><cr>

" Window switching
" [Option] + h, which is「˙」
" [Option] + j, which is「∆」
" [Option] + k, which is「˚」
" [Option] + l, which is「¬」
nnoremap ˙ :wincmd h<cr>
nnoremap ∆ :wincmd j<cr>
nnoremap ˚ :wincmd k<cr>
nnoremap ¬ :wincmd l<cr>

" Tab switching
" [Option] + [shift] + h, which is「Ó」
" [Option] + [shift] + l, which is「Ò」
nnoremap Ó :tabprev<cr>
nnoremap Ò :tabnext<cr>

" \qc to close quickfix
nnoremap <leader>qc :cclose<cr>

" Some general configurations
" Folding, disabled by default
set nofoldenable
set foldmethod=manual
set foldlevel=0
" Set file encoding format
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
if !has('nvim')
    set termencoding=utf-8
endif
set encoding=utf-8
" Set mouse mode for different modes (normal/visual/...), see :help mouse for details
" The configuration below means no mode is entered
set mouse=
" Other commonly used settings
set backspace=indent,eol,start
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set hlsearch
set number
set cursorline
set guicursor=n-v-c:block-Cursor/lCursor
set matchpairs+=<:>

" Load extra config (post step)
if filereadable(expand("~/.vimrc_extra_post"))
    source ~/.vimrc_extra_post
endif

" Load project-specific configurations
if filereadable("./.workspace.vim")
    source ./.workspace.vim
endif
```

### 3.21.2 `~/.config/nvim/lua/packer-plugins.lua`

* `mkdir -p ~/.config/nvim/lua`

```lua
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
-- Packer can manage itself
use 'wbthomason/packer.nvim'

-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

use { "catppuccin/nvim", as = "catppuccin" }
vim.cmd.colorscheme "catppuccin-frappe" -- catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha

-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
}
require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true
    }
}

-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

use {
    'goolord/alpha-nvim',
    requires = { 'echasnovski/mini.icons' },
    config = function ()
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
}

-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

use {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        require("which-key").setup({
            triggers = {} -- No automatic triggering
        })

        -- Keymap binding for buffer local keymaps
        vim.api.nvim_set_keymap('n', '<leader>?',
            [[<cmd>lua require('which-key').show({ global = false })<CR>]],
            { noremap = true, silent = true, desc = "Buffer Local Keymaps (which-key)" }
        )
    end
}

-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end)
```

# 4 Legacy Plugins

These are the plugins I have eliminated.

## 4.1 nerdtree

Home: [nerdtree](https://github.com/preservim/nerdtree)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'scrooloose/nerdtree'

" Configure F2 to open the file manager
nmap <f2> :NERDTreeToggle<cr>
" Configure F3 to locate the current file
nmap <f3> :NERDTreeFind<cr>

call plug#end()
```

**Usage:**

* `:NERDTreeToggle`: Open the file manager.
* `:NERDTreeFind`: Open the file manager, and locate the current file.

## 4.2 vim-gutentags

Home: [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'ludovicchabant/vim-gutentags'

" gutentags search project directory markers, stop recursion upwards upon encountering these files/directories
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

" Name of the generated data file
let g:gutentags_ctags_tagfile = '.tags'

" Enable support for both ctags and gtags:
let g:gutentags_modules = []
if executable('ctags')
    let g:gutentags_modules += ['ctags']
endif
if !has('nvim') && executable('gtags-cscope') && executable('gtags')
    let g:gutentags_modules += ['gtags_cscope']
endif

" Put all automatically generated ctags/gtags files in the ~/.cache/tags directory to avoid polluting the project directory
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" Configure ctags parameters by file type
function s:set_cfamily_configs()
    let g:gutentags_ctags_extra_args = ['--fields=+ailnSz']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
    " Configure Universal ctags specific parameters
    let g:ctags_version = system('ctags --version')[0:8]
    if g:ctags_version == "Universal"
        let g:gutentags_ctags_extra_args += ['--extras=+q', '--output-format=e-ctags']
    endif
endfunction
function s:set_python_configs()
    let g:gutentags_ctags_extra_args = ['--fields=+ailnSz']
    let g:gutentags_ctags_extra_args += ['--languages=python']
    let g:gutentags_ctags_extra_args += ['--python-kinds=-iv']
    " Configure Universal ctags specific parameters
    let g:ctags_version = system('ctags --version')[0:8]
    if g:ctags_version == "Universal"
        let g:gutentags_ctags_extra_args += ['--extras=+q', '--output-format=e-ctags']
    endif
endfunction
autocmd FileType c,cpp,objc call s:set_cfamily_configs()
autocmd FileType python call s:set_python_configs()

" Disable gutentags auto-loading of gtags database
let g:gutentags_auto_add_gtags_cscope = 0

" Enable advanced commands like :GutentagsToggleTrace
let g:gutentags_define_advanced_commands = 1

" Create ~/.cache/tags if it does not exist
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

call plug#end()
```

**Usage:**

* **`:GutentagsUpdate`: Manually trigger tag updates.**

**Trouble-shooting:**

1. `let g:gutentags_define_advanced_commands = 1`: Allows `gutentags` to enable some advanced commands and options
1. Run `:GutentagsToggleTrace`: It will log the output of `ctags/gtags` commands in vim's `message` log
   * `let g:gutentags_trace = 1`: Provides similar functionality
1. Save the file to trigger a database update
1. `:message`: Allows you to review the message log again

**FAQ:**

* `gutentags: gtags-cscope job failed, returned: 1`
    * **Reason 1: Switching branches in a `git` repository may cause the `gtagsdb` to become corrupted. `gutentags` uses a command like `gtags --incremental <gtagsdb-path>` to update the `gtagsdb`, which can result in a segmentation fault. This issue manifests as `gutentags: gtags-cscope job failed, returned: 1`.**
        * **Solution: Modify the `gutentags` source code to remove the `--incremental` parameter. Use the following command to modify it in one step: `sed -ri "s|'--incremental', *||g" ~/.vim/plugged/vim-gutentags/autoload/gutentags/gtags_cscope.vim`**
* `gutentags: ctags job failed, returned: 1`
    * **Reason 1: The installed version of ctags is too old. Reinstall a newer version.**
* How to disable:
    * `let g:gutentags_enabled = 0`
    * `let g:gutentags_dont_load = 1`

### 4.2.1 gutentags_plus

Home: [gutentags_plus](https://github.com/skywind3000/gutentags_plus)

**Without this plugin, we typically use `gtags` in the following way:**

1. **`set cscopeprg='gtags-cscope'`: Set the `cscope` command to point to `gtags-cscope`**
1. **`cscope add <gtags-path>/GTAGS`: Add the `gtagsdb` to `cscope`**
1. **`cscope find s <symbol>`: Start symbol indexing**

The plugin provides a command `GscopeFind` for `gtags` queries.

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'skywind3000/gutentags_plus'

" After querying, switch cursor to the quickfix window
let g:gutentags_plus_switch = 1

" Disable default mappings, as they conflict with the nerdcommenter plugin
let g:gutentags_plus_nomap = 1

" Define new mappings
nnoremap <leader>gd :GscopeFind g <c-r><c-w><cr>
nnoremap <leader>gr :GscopeFind s <c-r><c-w><cr>
nnoremap <leader>ga :GscopeFind a <c-r><c-w><cr>
nnoremap <leader>gt :GscopeFind t <c-r><c-w><cr>
nnoremap <leader>ge :GscopeFind e <c-r><c-w><cr>
nnoremap <leader>gf :GscopeFind f <c-r>=expand("<cfile>")<cr><cr>
nnoremap <leader>gi :GscopeFind i <c-r>=expand("<cfile>")<cr><cr>

call plug#end()
```

**Keymap Explanation:**

| Keymap   | Description                                |
|----------|--------------------------------------------|
| **`\gd`** | **Find the definition of the symbol under the cursor** |
| **`\gr`** | **Find references to the symbol under the cursor** |
| **`\ga`** | **Find assignments to the symbol under the cursor** |
| `\gt`    | Find the string under the cursor           |
| `\ge`    | Search the string under the cursor using `egrep pattern` |
| `\gf`    | Find the filename under the cursor         |
| **`\gi`** | **Find files that include the header under the cursor** |

### 4.2.2 vim-preview

Home: [vim-preview](https://github.com/skywind3000/vim-preview)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'skywind3000/vim-preview'

autocmd FileType qf nnoremap <buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <buffer> P :PreviewClose<cr>
" Map :PreviewScroll +1 and :PreviewScroll -1 to D and U respectively
autocmd FileType qf nnoremap <buffer> <c-e> :PreviewScroll +1<cr>
autocmd FileType qf nnoremap <buffer> <c-y> :PreviewScroll -1<cr>

call plug#end()
```

**Usage:**

* **In `quickfix`, press `p` to open the preview**
* **In `quickfix`, press `P` to close the preview**
* **`D`: Scroll down half a page in the preview**
* **`U`: Scroll up half a page in the preview**

### 4.2.3 rainbow

Home: [rainbow](https://github.com/luochen1990/rainbow)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'luochen1990/rainbow'

let g:rainbow_active = 1

call plug#end()
```

## 4.3 ALE

Home: [ALE](https://github.com/dense-analysis/ale)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'dense-analysis/ale'

" Disable status column + disable line highlights
let g:ale_sign_column_always = 0
let g:ale_set_highlights = 0

" Error and warning signs
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚡'

" Set linters and use only specified ones
" In my environment, gcc and g++ are not available among the Available Linters, but cc (Linter Aliases) is.
" The cc alias includes clang, clang++, gcc, and g++.
" The following configuration ensures that the active linter will be cc.
let g:ale_linters_explicit = 1
let g:ale_linters = {
  \   'c': ['gcc'],
  \   'cpp': ['g++'],
  \}

" This configuration sets the linter to cc, which is an alias that includes clang, clang++, gcc, and g++.
" By default, clang and clang++ are used. The following lines change it to gcc and g++.
let g:ale_c_cc_executable = 'gcc'
let g:ale_cpp_cc_executable = 'g++'
" Use gnu17 and gnu++17 to avoid issues with c17 and c++17 standards
let g:ale_c_cc_options = '-std=gnu17 -Wall'
let g:ale_cpp_cc_options = '-std=gnu++17 -Wall'

let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1

" Configure shortcuts for navigating warnings/errors
" [Ctrl] + j: Next warning/error
" [Ctrl] + k: Previous warning/error
nmap <silent> <c-k> <plug>(ale_previous_wrap)
nmap <silent> <c-j> <plug>(ale_next_wrap)

call plug#end()
```

**Usage:**

* **`:ALEInfo`: View configuration information; scroll to the bottom to see the command execution results**
* **How to configure `C/C++` projects: Different `C/C++` projects vary greatly in structure, and there are many build tools available. As a result, it's difficult for `ALE` to determine the correct compilation parameters for the current file. Therefore, `ALE` will try to read the `compile_commands.json` file in the project directory to obtain the necessary compilation parameters.**
* **Specify the header file path for third-party libraries. The environment variable name varies for different types of compilers. Here is an example using `gcc` and `g++`:**
    * `export C_INCLUDE_PATH=${C_INCLUDE_PATH}:<third party include path...>`
    * `export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:<third party include path...>`

**FAQ:**

1. **If the `linter` uses `gcc` or `g++`, even with syntax errors, no warning messages will appear. However, by using `:ALEInfo`, you can see the error messages. This happens because ALE identifies errors by the keyword `error`, but in my environment, `gcc` outputs compilation errors in Chinese as `错误`. As a result, ALE does not recognize these as errors. The solution is as follows:**
    1. `mv /usr/share/locale/zh_CN/LC_MESSAGES/gcc.mo /usr/share/locale/zh_CN/LC_MESSAGES/gcc.mo.bak`
    1. `mv /usr/local/share/locale/zh_CN/LC_MESSAGES/gcc.mo /usr/local/share/locale/zh_CN/LC_MESSAGES/gcc.mo.bak`
    * If you cannot find the `gcc.mo` file, you can use the `locate` command to search for it.

## 4.4 LanguageClient-neovim

Home: [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" Disabled by default. For some large projects, `ccls` initialization can be slow. Start it manually when needed with :LanguageClientStart.
let g:LanguageClient_autoStart = 0
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_selectionUI = 'quickfix'
let g:LanguageClient_diagnosticsList = v:null
let g:LanguageClient_hoverPreview = 'Never'
let g:LanguageClient_serverCommands = {}

nnoremap <leader>rd :call LanguageClient#textDocument_definition()<cr>
nnoremap <leader>rr :call LanguageClient#textDocument_references()<cr>
nnoremap <leader>rv :call LanguageClient#textDocument_hover()<cr>
nnoremap <leader>rn :call LanguageClient#textDocument_rename()<cr>

call plug#end()
```

**Install:**

* After entering the Vim interface, execute `:PlugInstall`. During installation, a script `install.sh` needs to be executed, which downloads a binary from GitHub. In mainland China, this download may time out and fail. You can manually install it using the following method:

```sh
# Assuming the project has already been downloaded locally via :PlugInstall
cd ~/.vim/plugged/LanguageClient-neovim

# Modify the URL
sed -i -r 's|([^/]?)https://github.com/|\1https://mirror.ghproxy.com/https://github.com/|g' install.sh

# Manually execute the installation script
./install.sh
```

**Usage:**

* **`:LanguageClientStart`: Since auto-start was disabled in the configuration above, you need to start it manually**
* **`:LanguageClientStop`: Stop the language client**
* **`:call LanguageClient_contextMenu()`: Open the operations menu**

**Keymap Explanation:**

| Keymap   | Description                                |
|----------|--------------------------------------------|
| **`\rd`** | **Find the definition of the symbol under the cursor** |
| **`\rr`** | **Find references to the symbol under the cursor** |
| **`\rv`** | **View the description of the symbol under the cursor** |
| **`\rn`** | **Rename the symbol under the cursor** |
| **`\hb`** | **Find the parent class of the symbol under the cursor (ccls only)** |
| **`\hd`** | **Find the subclasses of the symbol under the cursor (ccls only)** |

### 4.4.1 C-Family

#### 4.4.1.1 clangd

**Configuration(`~/.vimrc`):**

* **`clangd`: For related configuration, refer to [LanguageClient-neovim/wiki/Clangd](https://github.com/autozimu/LanguageClient-neovim/wiki/Clangd)**
* `clangd` cannot change the cache storage path; by default, it uses `${project}/.cache` as the cache directory
* **`clangd` searches for `compile_commands.json` in the path specified by the `--compile-commands-dir` parameter. If not found, it recursively searches in the current directory and the directories above each source file's location**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

" Omit common configs
let g:LanguageClient_serverCommands.c = ['clangd']
let g:LanguageClient_serverCommands.cpp = ['clangd']

call plug#end()
```

#### 4.4.1.2 ccls

It is not recommended, as large projects consume too many resources and often freeze.

**Configuration(`~/.vimrc`):**

* **`ccls`: For related configuration, refer to [ccls-project-setup](https://github.com/MaskRay/ccls/wiki/Project-Setup)**
* **`ccls` searches for `compile_commands.json` in the root directory of the project**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

" Omit common configs
let g:LanguageClient_settingsPath = expand('~/.vim/languageclient.json')
let g:LanguageClient_serverCommands.c = ['ccls']
let g:LanguageClient_serverCommands.cpp = ['ccls']
nnoremap <leader>hb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<cr>
nnoremap <leader>hd :call LanguageClient#findLocations({'method':'$ccls/inheritance','derived':v:true})<cr>

call plug#end()
```

**`~/.vim/languageclient.json`**

* All paths must be absolute paths; `~` cannot be used

```json
{
    "ccls": {
        "cache": {
            "directory": "/root/.cache/LanguageClient"
        }
    }
}
```

### 4.4.2 Java-jdtls

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

" Omit common configs
let g:LanguageClient_serverCommands.java = ['/usr/local/bin/jdtls', '-data', getcwd()]

call plug#end()
```

**Create a script with the full path `/usr/local/bin/jdtls` containing the following content:**

```sh
#!/usr/bin/env sh

server={{ your server installation location }}

java \
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \
    -Dosgi.bundles.defaultStartLevel=4 \
    -Declipse.product=org.eclipse.jdt.ls.core.product \
    -noverify \
    -Xms1G \
    -jar $server/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/plugins/org.eclipse.equinox.launcher_1.*.jar \
    -configuration $server/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/config_linux/ \
    --add-modules=ALL-SYSTEM \
    --add-opens java.base/java.util=ALL-UNNAMED \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    "$@"
```

**FAQ:**

* Cannot access classes in the JDK and third-party libraries.
* For Maven projects, if there are additional directories in the standard directory structure, such as `<project-name>/src/main/<extra_dir>/com`, `jdt.ls` cannot automatically scan the entire project. The file will only be added to the parsing list if opened manually.

## 4.5 Code Completion

### 4.5.1 YouCompleteMe

Home: [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe)

**Install:**

```sh
# Define a function to adjust GitHub URLs to speed up the download process. This function will be used multiple times
function setup_github_repo() {
    gitmodules=( $(find . -name '.gitmodules' -type f) )
    for gitmodule in ${gitmodules[@]}
    do
        echo "setup github repo for '${gitmodule}'"
        sed -i -r 's|([^/]?)https://github.com/|\1https://mirror.ghproxy.com/https://github.com/|g' ${gitmodule}
    done

    git submodule sync --recursive
}

cd ~/.vim/plugged
git clone https://mirror.ghproxy.com/https://github.com/ycm-core/YouCompleteMe.git --depth 1
cd YouCompleteMe

# Recursively download ycm's submodules
git submodule update --init --recursive

# If the download times out, repeat the following two commands until it completes
setup_github_repo
git submodule update --init --recursive

# Compile
python3 install.py --clang-completer
```

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'ycm-core/YouCompleteMe'

" The global configuration file for ycm takes effect when the compile_commands.json file is not present
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
" Disable ycm from asking whether to use the global configuration each time a file is opened
let g:ycm_confirm_extra_conf = 0

let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings = 1
let g:ycm_key_invoke_completion = '<c-z>'
set completeopt=menu,menuone

noremap <c-z> <nop>

let g:ycm_semantic_triggers =  {
           \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
           \ 'cs,lua,javascript': ['re!\w{2}'],
           \ }

call plug#end()
```

**How it worked:**

1. **Using `compilation database`: If there is a `compile_commands.json` in the current directory, it reads this file to compile and parse the code**
1. **`.ycm_extra_conf.py`: If there is no `compilation database`, `ycm` will recursively search upward in the directory hierarchy for the first `.ycm_extra_conf.py` file. If none is found, it will load the global configuration (if the `g:ycm_global_ycm_extra_conf` parameter is set)**

**Configure `~/.ycm_extra_conf.py`, with the following content (for C/C++, applicable to most simple projects), for reference only**

```python
def Settings(**kwargs):
    if kwargs['language'] == 'cfamily':
        return {
            'flags': ['-x', 'c++', '-Wall', '-Wextra', '-Werror'],
        }
```

**Usage:**

* **By default, only generic completion is available, such as adding already existing characters from the file to the dictionary. This way, if the same string is typed again, it will suggest completion**
* **For semantic completion, you can generate a `compile_commands.json` using build tools like `cmake` and place it in the root directory of the project. Then, open the project in vim to enable semantic completion**
* `[Ctrl] + n`: Next entry
* `[Ctrl] + p`: Previous entry

### 4.5.2 vim-javacomplete2

Home: [vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'artur-shaik/vim-javacomplete2'

" Disable default configuration options
let g:JavaComplete_EnableDefaultMappings = 0
" Enable code completion
autocmd FileType java setlocal omnifunc=javacomplete#Complete
" Import related
autocmd FileType java nmap <leader>jI <Plug>(JavaComplete-Imports-AddMissing)
autocmd FileType java nmap <leader>jR <Plug>(JavaComplete-Imports-RemoveUnused)
autocmd FileType java nmap <leader>ji <Plug>(JavaComplete-Imports-AddSmart)
autocmd FileType java nmap <leader>jii <Plug>(JavaComplete-Imports-Add)
" Code generation related
autocmd FileType java nmap <leader>jM <Plug>(JavaComplete-Generate-AbstractMethods)
autocmd FileType java nmap <leader>jA <Plug>(JavaComplete-Generate-Accessors)
autocmd FileType java nmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
autocmd FileType java nmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
autocmd FileType java nmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
autocmd FileType java nmap <leader>jts <Plug>(JavaComplete-Generate-ToString)
autocmd FileType java nmap <leader>jeq <Plug>(JavaComplete-Generate-EqualsAndHashCode)
autocmd FileType java nmap <leader>jc <Plug>(JavaComplete-Generate-Constructor)
autocmd FileType java nmap <leader>jcc <Plug>(JavaComplete-Generate-DefaultConstructor)
autocmd FileType java vmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
autocmd FileType java vmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
autocmd FileType java vmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
" 其他
autocmd FileType java nmap <silent> <buffer> <leader>jn <Plug>(JavaComplete-Generate-NewClass)
autocmd FileType java nmap <silent> <buffer> <leader>jN <Plug>(JavaComplete-Generate-ClassInFile)

call plug#end()
```

## 4.6 vim-grepper

Home: [vim-grepper](https://github.com/mhinz/vim-grepper)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'mhinz/vim-grepper'

call plug#end()
```

**Usage:**

* `:Grepper`

## 4.7 vim-signify

Home: [vim-signify](https://github.com/mhinz/vim-signify)

**Configuration(`~/.vimrc`):**

```vim
call plug#begin()

" ......................
" .....Other Plugins....
" ......................

Plug 'mhinz/vim-signify'

call plug#end()
```

**Usage:**

* `set signcolumn=yes`，有改动的行会标出
* `:SignifyDiff`：以左右分屏的方式对比当前文件的差异

# 5 vim-script

## 5.1 Tips

1. `filereadable`无法识别`~`，需要用`expand`，例如`filereadable(expand('~/.vim/gtags.vim'))`
1. 函数名要用大写字母开头，或者`s:`开头。大写字母开头表示全局可见，`s:`开头表示当前脚本可见
1. `exists('&cscopequickfix')`：判断是否存在参数`cscopequickfix`
1. `has('nvim')`：判断是否启用了某功能

# 6 nvim

## 6.1 Install

```sh
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout v0.11.2
cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo  && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
```

Or Install from Nvim development (prerelease) build (Prefer)

```sh
wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
tar -zxvf nvim-linux-x86_64.tar.gz
```

### 6.1.1 Node Version Management

**[nvm](https://github.com/nvm-sh/nvm):**

```sh
nvm ls-remote
nvm install v16.19.0
nvm install v20.11.1
nvm list
nvm use v16.19.0
nvm alias default v16.19.0
```

**[n](https://github.com/tj/n)**

```sh
npm install -g n
n install 16.19.0
n install 20.11.1
n list
n 16.19.0 # use this version
```

## 6.2 config path

```vim
" ~/.config/nvim
:echo stdpath('config')
" ~/.local/share/nvim
:echo stdpath('data')
" ~/.cache/nvim
:echo stdpath('cache')
:echo stdpath('config_dirs')
:echo stdpath('data_dirs')
```

## 6.3 nvim share configuration of vim

`nvim`和`vim`使用不同的目录来管理配置文件，通过软连接就可以实现共享配置，如下：

```sh
# nvim's config file is ~/.config/nvim/init.vim
mkdir -p ~/.vim ~/.vim/plugged
mkdir -p ~/.config
ln -sfn ~/.vim ~/.config/nvim
ln -sfn ~/.vimrc ~/.config/nvim/init.vim

# plug manager and plug
mkdir -p ~/.local/share/nvim/site/autoload
ln -sfn ~/.vim/autoload/plug.vim ~/.local/share/nvim/site/autoload/plug.vim
ln -sfn ~/.vim/plugged ~/.local/share/nvim/plugged
```

## 6.4 Tips

* 可能会提示`Vimspector unavailable: Requires Vim compiled with +python3`之类的问题：
    * `:checkhealth`进行自检，这里会提示安装`pynvim`
    * `let g:python3_host_prog = '/path/to/your/python3'`
* 在一个新的环境，安装完`nvim`后，最好都用`checkhealth`检查一遍，否则很多插件可能会因为依赖`python`等模块而无法正常工作，例如`LeaderF`
* `node`用`16.19`版本，可以用`nvm install v16.19.0`进行安装

# 7 Tips

## 7.1 Large Files Run Slowly

**禁止加载所有插件**

```sh
vim -u NONE <big file>
```

## 7.2 Export Settings

**Example 1**

```vim
:redir! > vim_keys.txt
:silent verbose map
:redir END
```

**Example 2**
```vim
:redir! > vim_settings.txt
:silent set all
:redir END
```

## 7.3 Save and Exit Slowly in Large Project

在大型工程中文件保存退出非常慢，发现是`vim-gutentags`插件，及其相关配置导致的。在项目配置文件`.workspace.vim`中添加如下内容进行禁用：

```
let g:gutentags_enabled = 0
let g:gutentags_dont_load = 1
```

## 7.4 How to show which key I hit

1. Enter normal mode.
1. Type `:map` then press `<c-v>`.
1. Type the key you wanted, then it interpreters it into the actual value.

## 7.5 Copy text through SSH

[nvim-osc52](https://github.com/ojroques/nvim-osc52)

> Note: As of Neovim 10.0 (specifically since [this PR](https://github.com/neovim/neovim/pull/25872)), native support for OSC52 has been added and therefore this plugin is now obsolete. Check :h clipboard-osc52 for more details.

* `:checkhealth clipboard`: Check if there's clipboard can be used.
    * `tmux` can provide a default clipboard.
* `Item2 Config`: General -> Selection -> Applications in terminal may access clipboard.

## 7.6 Filter through an external shell command

* `:%!xxd`
* `:%!hexdump -C`
* `:1,5!sort`

## 7.7 Display Info Page

* `:intro`

# 8 Reference

* **[《Vim 中文速查表》](https://github.com/skywind3000/awesome-cheatsheets/blob/master/editors/vim.txt)**
* **[如何在 Linux 下利用 Vim 搭建 C/C++ 开发环境?](https://www.zhihu.com/question/47691414)**
* **[Vim 8 中 C/C++ 符号索引：GTags 篇](https://zhuanlan.zhihu.com/p/36279445)**
* **[Vim 8 中 C/C++ 符号索引：LSP 篇](https://zhuanlan.zhihu.com/p/37290578)**
* **[三十分钟配置一个顺滑如水的 Vim](https://zhuanlan.zhihu.com/p/102033129)**
* **[CentOS Software Repo](https://www.softwarecollections.org/en/scls/user/rhscl/)**
* **[《Vim 中文版入门到精通》](https://github.com/wsdjeg/vim-galore-zh_cn)**
* **[VimScript 五分钟入门（翻译）](https://zhuanlan.zhihu.com/p/37352209)**
* **[使用 Vim 搭建 Java 开发环境](https://spacevim.org/cn/use-vim-as-a-java-ide/)**
* [如何优雅的使用 Vim（二）：插件介绍](https://segmentfault.com/a/1190000014560645)
* [打造 vim 编辑 C/C++ 环境](https://carecraft.github.io/language-instrument/2018/06/config_vim/)
* [Vim2021：超轻量级代码补全系统](https://zhuanlan.zhihu.com/p/349271041)
* [How To Install GCC on CentOS 7](https://linuxhostsupport.com/blog/how-to-install-gcc-on-centos-7/)
* [8.x版本的gcc以及g++](https://www.softwarecollections.org/en/scls/rhscl/devtoolset-8/)
* [VIM-Plug安装插件时，频繁更新失败，或报端口443被拒绝等](https://blog.csdn.net/htx1020/article/details/114364510)
* [Cannot find color scheme 'gruvbox' #85](https://github.com/morhetz/gruvbox/issues/85)
* 《鸟哥的Linux私房菜》
* [Mac 的 Vim 中 delete 键失效的原因和解决方案](https://blog.csdn.net/jiang314/article/details/51941479)
* [解决linux下vim中文乱码的方法](https://blog.csdn.net/zhangjiarui130/article/details/69226109)
* [vim-set命令使用](https://www.jianshu.com/p/97d34b62d40d)
* [解決 ale 的 gcc 不顯示錯誤 | 把 gcc 輸出改成英文](https://aben20807.blogspot.com/2018/03/1070302-ale-gcc-gcc.html)
* [Mapping keys in Vim - Tutorial](https://vim.fandom.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_2))
* [centos7 安装GNU GLOBAL](http://www.cghlife.com/tool/install-gnu-global-on-centos7.html)
* [The Vim/Cscope tutorial](http://cscope.sourceforge.net/cscope_vim_tutorial.html)
* [GNU Global manual](https://phenix3443.github.io/notebook/emacs/modes/gnu-global-manual.html)
* [Vim Buffers, Windows and Tabs — an overview](https://medium.com/@paulodiovani/vim-buffers-windows-and-tabs-an-overview-8e2a57c57afa)
