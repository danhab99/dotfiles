# Check if a directory name was provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a component name."
  exit 1
fi

# Create a new directory with the component name
mkdir "$1"

# Create a .tsx file with component skeleton
cat <<EOF > "$1/$1.tsx"
import clsx from "clsx";
import style from "./$1.module.css";

export type ${1}Props = {};

export function ${1}(props: ${1}Props) {
  return <div className={clsx([style.${1}])}></div>;
}
EOF

# Create a Storybook story file for the component
cat <<EOF > "$1/$1.stories.tsx"
import type { Meta, StoryObj } from '@storybook/react';
import { $1 } from './$1';

// More on how to set up stories at:
// https://storybook.js.org/docs/writing-stories#default-export
const meta: Meta<typeof $1> = {
  title: '${1}/$1',
  component: $1,
  parameters: {
    layout: 'centered',
  },
  tags: ['autodocs'],
  args: {},
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Test: Story = {
  args: {
    // Add story args here
  }
};
EOF
