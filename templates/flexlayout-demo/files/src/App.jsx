import React, { useRef, useState } from 'react';
import * as FlexLayout from 'flexlayout-react';
import 'flexlayout-react/style/light.css';

const App = () => {
  const layoutRef = useRef(null);
  const [addCounter, setAddCounter] = useState(1);

  // Initial layout configuration
  const json = {
    global: {
      tabEnableFloat: true, // This enables the float/pop-out functionality
      tabSetEnableMaximize: true,
      tabSetEnableClose: true,
      tabEnableDrag: true,
      tabEnableRename: true,
    },
    borders: [],
    layout: {
      type: 'row',
      weight: 100,
      children: [
        {
          type: 'tabset',
          weight: 50,
          children: [
            {
              type: 'tab',
              name: 'Welcome',
              component: 'welcome',
            },
            {
              type: 'tab',
              name: 'About FlexLayout',
              component: 'about',
            },
          ],
        },
        {
          type: 'tabset',
          weight: 50,
          children: [
            {
              type: 'tab',
              name: 'Demo Panel 1',
              component: 'demo',
              config: { id: 1 },
            },
            {
              type: 'tab',
              name: 'Demo Panel 2',
              component: 'demo',
              config: { id: 2 },
            },
          ],
        },
      ],
    },
  };

  const [model] = useState(FlexLayout.Model.fromJson(json));

  // Factory function to create components for each tab
  const factory = (node) => {
    const component = node.getComponent();
    const config = node.getConfig();

    if (component === 'welcome') {
      return <WelcomePanel />;
    }

    if (component === 'about') {
      return <AboutPanel />;
    }

    if (component === 'demo') {
      return <DemoPanel id={config?.id || 0} />;
    }

    if (component === 'dynamic') {
      return <DynamicPanel id={config?.id || 0} />;
    }

    return <div>Unknown component: {component}</div>;
  };

  // Add a new tab dynamically
  const handleAddTab = () => {
    const newTabJson = {
      type: 'tab',
      name: `Dynamic Tab ${addCounter}`,
      component: 'dynamic',
      config: { id: addCounter },
    };

    layoutRef.current.addTabToActiveTabSet(newTabJson);
    setAddCounter(addCounter + 1);
  };

  return (
    <div style={{ width: '100vw', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '10px', backgroundColor: '#2c3e50', color: 'white' }}>
        <h1 style={{ margin: '5px 0', fontSize: '20px' }}>FlexLayout React Demo</h1>
        <div style={{ marginTop: '10px' }}>
          <button
            onClick={handleAddTab}
            style={{
              padding: '8px 15px',
              backgroundColor: '#3498db',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '14px',
            }}
          >
            Add New Tab
          </button>
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'hidden' }}>
        <FlexLayout.Layout ref={layoutRef} model={model} factory={factory} />
      </div>
    </div>
  );
};

const WelcomePanel = () => {
  return (
    <div className="info-panel">
      <h2>Welcome to FlexLayout React Demo! 🎉</h2>
      <p>
        This demo showcases the powerful features of the FlexLayout library, particularly the
        <strong> "Float" button functionality</strong> that allows you to pop tabs out into separate
        windows.
      </p>

      <h3>How to Use the "Float" Feature:</h3>
      <ol>
        <li>
          <strong>Look for the Float Button:</strong> Hover over any tab and look at the tab header
          buttons. You'll see several icons including a "window" icon (float button).
        </li>
        <li>
          <strong>Click the Float Button:</strong> Click the window/float icon to pop the tab out
          into a separate browser window.
        </li>
        <li>
          <strong>The Tab Becomes a Floating Window:</strong> The tab will open in a new browser
          window that you can move, resize, and position anywhere on your screen.
        </li>
        <li>
          <strong>Return the Window:</strong> In the floating window, click the "Dock" button to
          return it back to the main layout.
        </li>
      </ol>

      <h3>Try It Now!</h3>
      <p>
        Try floating any of the tabs in this demo by clicking the float button in the tab header.
        You can have multiple floating windows open at the same time!
      </p>

      <h3>Other Features to Explore:</h3>
      <ul>
        <li>
          <strong>Drag and Drop:</strong> Click and drag tabs to rearrange them or move them between
          tabsets
        </li>
        <li>
          <strong>Split Views:</strong> Drag a tab to the edge of a panel to create split layouts
        </li>
        <li>
          <strong>Maximize:</strong> Click the maximize button to make a tab full screen
        </li>
        <li>
          <strong>Close Tabs:</strong> Use the X button to close tabs (except this one!)
        </li>
        <li>
          <strong>Add Tabs:</strong> Click "Add New Tab" in the header to create new tabs
          dynamically
        </li>
      </ul>
    </div>
  );
};

const AboutPanel = () => {
  return (
    <div className="info-panel">
      <h2>About FlexLayout</h2>
      <p>
        FlexLayout is a powerful React component library that provides a sophisticated docking and
        tabbing layout system for building complex multi-panel applications.
      </p>

      <h3>Key Features:</h3>
      <ul>
        <li>
          <strong>Floating Windows:</strong> Pop out tabs into separate browser windows (the "show
          window" feature)
        </li>
        <li>
          <strong>Drag and Drop:</strong> Intuitive drag-and-drop interface for rearranging panels
        </li>
        <li>
          <strong>Split Layouts:</strong> Create complex horizontal and vertical splits
        </li>
        <li>
          <strong>Tab Management:</strong> Multiple tabs within panels with easy navigation
        </li>
        <li>
          <strong>Persistence:</strong> Save and restore layout configurations
        </li>
        <li>
          <strong>Customizable:</strong> Extensive theming and styling options
        </li>
      </ul>

      <h3>The Float/Pop-out Feature:</h3>
      <p>
        The "float" or "pop-out" feature is enabled by setting <code>tabEnableFloat: true</code> in
        the global configuration. When enabled, each tab gets a float button that opens it in a new
        browser window.
      </p>

      <h3>How It Works:</h3>
      <p>
        When you click the float button on a tab, FlexLayout opens a new browser window and renders
        the tab's content in that window. The floating window maintains a connection to the main
        application and can be docked back at any time. This is particularly useful for:
      </p>
      <ul>
        <li>Multi-monitor setups where you want to spread your workspace across screens</li>
        <li>Comparing content side-by-side in separate windows</li>
        <li>Keeping reference material visible while working in the main window</li>
      </ul>

      <h3>Configuration:</h3>
      <p>
        The float functionality is controlled by the <code>tabEnableFloat</code> option in the
        layout's global configuration. You can also control other behaviors like:
      </p>
      <ul>
        <li>
          <code>tabEnableDrag</code> - Allow dragging tabs
        </li>
        <li>
          <code>tabEnableRename</code> - Allow renaming tabs
        </li>
        <li>
          <code>tabSetEnableMaximize</code> - Allow maximizing tabs
        </li>
        <li>
          <code>tabSetEnableClose</code> - Allow closing tabs
        </li>
      </ul>
    </div>
  );
};

const DemoPanel = ({ id }) => {
  const [count, setCount] = useState(0);

  return (
    <div className="content-panel">
      <h1>Demo Panel {id}</h1>
      <p>
        This is a demo panel to show interactive content. Try floating this tab by clicking the
        float button in the tab header above!
      </p>

      <div className="demo-controls">
        <h3>Interactive Counter:</h3>
        <p>Current count: {count}</p>
        <button onClick={() => setCount(count + 1)}>Increment</button>
        <button onClick={() => setCount(count - 1)}>Decrement</button>
        <button onClick={() => setCount(0)}>Reset</button>
      </div>

      <div className="demo-controls">
        <h3>Instructions:</h3>
        <ol>
          <li>Hover over this tab's header to see the available buttons</li>
          <li>Click the "float" button (window icon) to pop this panel into a separate window</li>
          <li>The counter state will be preserved when you float/dock the window</li>
          <li>You can have multiple panels floated at the same time</li>
          <li>Click "Dock" in the floating window to return it to the main layout</li>
        </ol>
      </div>

      <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#e8f4f8', borderRadius: '5px' }}>
        <h4>💡 Tip:</h4>
        <p>
          The float feature is perfect for multi-monitor setups! You can move floated windows to
          different screens while keeping the main layout on your primary monitor.
        </p>
      </div>
    </div>
  );
};

const DynamicPanel = ({ id }) => {
  return (
    <div className="content-panel">
      <h1>Dynamic Panel {id}</h1>
      <p>This tab was created dynamically at runtime!</p>
      <p>
        You can add as many tabs as you want using the "Add New Tab" button in the header.
        Each dynamically created tab can also be floated into its own window.
      </p>

      <div className="demo-controls">
        <h3>Features of Dynamic Tabs:</h3>
        <ul>
          <li>Created programmatically at runtime</li>
          <li>Can be floated, dragged, and rearranged like any other tab</li>
          <li>Can be closed by clicking the X button</li>
          <li>Maintains its own state and content</li>
        </ul>
      </div>

      <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#fff3cd', borderRadius: '5px' }}>
        <h4>🎯 Try This:</h4>
        <p>
          1. Create several dynamic tabs<br />
          2. Float a few of them into separate windows<br />
          3. Arrange them across your screens<br />
          4. Dock them back in different positions
        </p>
      </div>
    </div>
  );
};

export default App;
