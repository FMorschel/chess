---
applyTo: '**.dart'
---

# General Dart Editing Instructions

## After Making Changes

Always request to run the "Format document" command after making any edits to Dart files.

This ensures:
- Consistent code formatting across the project
- Compliance with Dart formatting standards
- Proper indentation and spacing
- Lint rule compliance where applicable

## Best Practices

### 1. **Incremental Changes**
Make changes incrementally and format after each significant edit to catch formatting issues early.

### 2. **Empty Line Preservation**
**CRITICAL**: Never remove empty lines unless there are multiple consecutive empty lines (more than one). Empty lines are structural elements that separate different code sections and must be preserved to maintain code organization and readability.

### 3. **Strings**
- Use single quotes for strings unless interpolation is needed.
- Use triple quotes for multi-line strings.
- Keep strings under the 80 character limit.
  - If the above is not possible, break the string into multiple lines using a new string by the side like:
  'This is a really big string that exceeds the 80 character limit, so we '
  'break it into multiple lines.'
  - Always prefer empty spaces to be at the end of the line rather than at the beginning of the next line.

### 4. **File out-line**
- Ordering:

1. Imports (**Whenever possible use relative imports** - lint diagnostic if not done properly)
2. Exports
3. Part directives
4. Typedefs
5. Class/Mixin/Enum/Extension type declarations
6. Extension declarations

Private declarations (starting with _ or unnamed extensions) should come after the public declarations.

Within each category above, sort alphabetically by name (which should enforce the _ convention but not necessarily the unnamed).

### 5. **Extensions**
- Use extensions to add functionality to existing types without modifying them.
- Name extensions clearly to indicate their purpose only when the functionality is intended to be used publicly.
- If the functionality is private, prefer unnamed extensions.
- If multiple functionalities are intended, name the extension with the extendee name appended with `Ext` like: `extension on List<String>` becomes `StringListExt`.

## Workflow

1. Make your code changes
2. Request "Format document" vscode command. Only ask to run on terminal if that one failed for some reason.
3. Proceed with additional changes if needed

This workflow ensures that all Dart files maintain consistent formatting and follow the established coding standards.
