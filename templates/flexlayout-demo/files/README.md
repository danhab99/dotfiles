# FlexLayout React Demo

This is a comprehensive demonstration of the FlexLayout React library, with a special focus on the **"Float" (pop-out window)** feature.

## What is FlexLayout?

FlexLayout is a powerful React component library that provides a sophisticated docking and tabbing layout system. It's perfect for building complex multi-panel applications like IDEs, dashboards, or any application that needs flexible window management.

## The "Show Window" / Float Feature

The **float feature** (also known as "pop-out" or "show window") allows users to pop individual tabs out into separate browser windows. This is one of FlexLayout's most powerful features.

### How to Use the Float Feature:

1. **Find the Float Button**: Hover over any tab header and look for the window/float icon button
2. **Click to Float**: Click the float button to pop the tab into a new browser window
3. **Move and Resize**: The floating window can be moved and resized like any browser window
4. **Dock Back**: Click the "Dock" button in the floating window to return it to the main layout

### Why Use Floating Windows?

- **Multi-Monitor Support**: Spread your workspace across multiple monitors
- **Side-by-Side Comparison**: Compare content in separate windows
- **Reference Material**: Keep documentation or reference panels visible while working
- **Flexible Workflow**: Organize your workspace exactly how you want it

## Getting Started

### Prerequisites

- Nix with flakes enabled
- Node.js 20+ (provided by the Nix shell)

### Installation

1. Enter the Nix development shell:
   ```bash
   nix develop
   ```

2. Install dependencies:
   ```bash
   make install
   ```

### Running the Demo

Start the development server:
```bash
make dev
```

The application will be available at `http://localhost:3000`

### Building for Production

```bash
make build
```

The built files will be in the `dist` directory.

## Features Demonstrated

### 1. Floating/Pop-out Windows
- Click the float button on any tab to pop it into a separate window
- Multiple windows can be floated simultaneously
- Floating windows can be docked back at any time

### 2. Drag and Drop
- Drag tabs to rearrange them within a tabset
- Drag tabs between different tabsets
- Drag tabs to the edges to create new splits

### 3. Split Layouts
- Horizontal and vertical splits
- Nested splits for complex layouts
- Adjustable split ratios by dragging dividers

### 4. Dynamic Tab Management
- Add new tabs programmatically
- Close tabs (with configurable close buttons)
- Rename tabs (double-click on tab name)

### 5. Maximize/Minimize
- Maximize a tab to full screen
- Restore to original position

## Configuration

The float feature is enabled in the layout configuration:

```javascript
const json = {
  global: {
    tabEnableFloat: true,  // Enable floating windows
    tabSetEnableMaximize: true,
    tabSetEnableClose: true,
    tabEnableDrag: true,
    tabEnableRename: true,
  },
  // ... rest of layout configuration
};
```

## Key Configuration Options

- `tabEnableFloat`: Enable/disable the float button on tabs
- `tabEnableDrag`: Allow dragging tabs
- `tabEnableRename`: Allow renaming tabs (double-click)
- `tabSetEnableMaximize`: Allow maximizing tabs
- `tabSetEnableClose`: Allow closing tabs
- `tabEnableClose`: Control close button on individual tabs

## Project Structure

```
.
├── flake.nix           # Nix development environment
├── makefile            # Build and run commands
├── package.json        # npm dependencies
├── vite.config.js      # Vite configuration
├── index.html          # HTML entry point
└── src/
    ├── main.jsx        # React entry point
    ├── App.jsx         # Main application with FlexLayout
    └── index.css       # Global styles
```

## Learn More

- [FlexLayout GitHub](https://github.com/caplin/FlexLayout)
- [FlexLayout Documentation](https://rawgit.com/caplin/FlexLayout/master/examples/demo/index.html)
- [React Documentation](https://react.dev)
- [Vite Documentation](https://vitejs.dev)

## Tips and Tricks

1. **Multi-Monitor Setup**: Float panels to different monitors for maximum productivity
2. **Save Layout**: FlexLayout supports saving and restoring layouts (not implemented in this demo)
3. **Custom Components**: Each tab can render any React component
4. **Theming**: FlexLayout supports light and dark themes (this demo uses light theme)
5. **Persistence**: You can serialize the layout model to JSON and restore it later

## Troubleshooting

### Float button not visible
- Make sure `tabEnableFloat: true` is set in the global configuration
- Hover over the tab header to see all available buttons

### Floating window doesn't dock back
- Click the "Dock" button in the floating window's header
- If the button is not visible, check that the floating window is properly connected

### Performance issues
- Limit the number of simultaneously floating windows
- Use React.memo for complex tab components
- Consider virtualization for large datasets

## License

This demo is provided as-is for educational purposes.
