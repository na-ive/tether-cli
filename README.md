# Tether v1.0.0

> Context Engine for AI-Powered Development

Tether provides intelligent context management for AI coding assistants, ensuring they understand your project's stack, conventions, and design philosophy.

## Features

- **Smart Project Detection** - Auto-detect frameworks, languages, and styling tools
- **Design Tokens** - Project-specific styling rules in `.tether/design-tokens.md`
- **Git Integration** - Safe commits, rollbacks, and history tracking
- **Modular Architecture** - Clean, maintainable codebase
- **Multi-Platform** - Web (Next.js, React, Vue) + Mobile (React Native, Expo)

---

## Quick Start

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/na-ive/tether-cli/main/install.sh | bash
```

### First Use

```bash
# Navigate to your project
cd my-project

# Detect project settings
tether-cli detect

# This creates:
# .tether/project.yaml       (auto-detected config)
# .tether/design-tokens.md   (template for your styling rules)

# Edit design tokens for your project
vim .tether/design-tokens.md

# Start coding
tether-cli "create a login page with form validation"
```

### Setup Alias (Recommended)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
alias tether='tether-cli'
```

Then use shorter commands:

```bash
tether detect
tether "create dashboard"
tether rollback
```

---

## Repository Structure

This is the **Starter Kit** (public repo) with examples and templates:

```
tether-cli/
├── install.sh                    # Main installer
├── README.md                     # This file
├── LICENSE                       # MIT License
│
├── docs/
│   ├── getting-started.md        # Installation & setup guide
│   ├── creating-rules.md         # How to create custom rules
│   └── design-tokens.md          # Design tokens guide
│
├── global/                       # Global rules (all projects)
│   └── example.md                # Example: coding standards
│
├── stacks/
│   ├── web/                      # Web frameworks
│   │   ├── next-app.md           # Next.js App Router
│   │   ├── next-pages.md         # Next.js Pages Router
│   │   ├── react-vite.md         # React + Vite
│   │   └── vue-nuxt.md           # Vue + Nuxt
│   │
│   └── mobile/                   # Mobile frameworks
│       ├── expo.md               # Expo / Expo Router
│       └── react-native.md       # React Native CLI
│
├── designs/
│   ├── foundations/              # Styling tools
│   │   ├── tailwind.md           # Tailwind CSS utilities
│   │   ├── styled-components.md  # CSS-in-JS patterns
│   │   └── css-modules.md        # CSS Modules
│   │
│   └── systems/                  # Design philosophies (manual)
│       ├── brutalism.md          # Brutalist design
│       ├── material-you.md       # Material Design 3
│       └── minimalism.md         # Minimalist design
│
├── presets/                      # Quick start configurations
│   ├── web-saas-starter.md       # SaaS app preset
│   └── mobile-app-starter.md     # Mobile app preset
│
└── examples/                     # Complete project examples
    ├── nextjs-dashboard/
    │   ├── .tether/
    │   │   ├── project.yaml
    │   │   └── design-tokens.md
    │   └── .tether-context.md
    │
    └── expo-app/
        ├── .tether/
        │   ├── project.yaml
        │   └── design-tokens.md
        └── .tether-context.md
```

---

## Project Configuration

When you run `tether detect`, it creates two files:

### 1. `.tether/project.yaml` (Auto-Generated)

Technical configuration auto-detected from your project:

```yaml
detected_at: 2026-01-10 10:30:00

project:
  package_manager: pnpm
  language: typescript
  framework: next-app # Auto-detected
  styling_foundation: tailwind # Auto-detected from package.json
  design_system: none # Edit manually (brutalism, material-you, etc)

conventions:
  indent: 2
  quotes: single
  semi: true
```

**Note:** `design_system` must be set manually as it represents design philosophy, not a library.

### 2. `.tether/design-tokens.md` (Template - Edit This!)

Project-specific styling rules that AI will read:

```markdown
# Design Tokens & Theming

This file contains project-specific styling rules. The AI will use this context.

## Colors

- Primary: #3b82f6
- Secondary: #64748b
- Accent: #10b981

## Typography

- Font Family: Inter, sans-serif
- Base Size: 16px
- Headings: font-bold

## Spacing

- Base unit: 4px
- Container max-width: 1280px

## Components

- Buttons: rounded-md, px-6 py-2
- Cards: shadow-lg, rounded-lg
- Inputs: border-2, focus:ring-2
```

**This is where you define your project's unique styling conventions!**

### 3. `.tether-context.md` (Optional - Create Manually)

Project goals and requirements:

```markdown
# Project Context

Building a SaaS dashboard for project management.

## Key Features

- Team collaboration
- Real-time updates
- Mobile-first design

## Technical Requirements

- TypeScript strict mode
- Accessibility (WCAG AA)
- Performance budget: <3s load time
```

---

## Design Systems vs Foundations

Tether separates **design philosophy** from **styling tools**:

### Design Systems (Manual Configuration)

Philosophy/aesthetic approach - set manually in `project.yaml`:

- **brutalism** - Raw, bold, functional
- **material-you** - Dynamic, adaptive (Material Design 3)
- **minimalism** - Less is more, generous whitespace
- **custom** - Your own design philosophy

**Example:**

```yaml
# Edit .tether/project.yaml
project:
  design_system: brutalism # Set manually
```

### Styling Foundations (Auto-Detected)

Implementation tools - detected from `package.json`:

- **tailwind** - Tailwind CSS
- **styled-components** - CSS-in-JS
- **emotion** - CSS-in-JS alternative
- **css-modules** - Scoped CSS
- **sass** - CSS preprocessor

**Auto-detected from your dependencies.**

### Design Tokens (Project-Specific)

Your unique styling rules in `.tether/design-tokens.md`:

- Exact color values
- Typography specs
- Component conventions
- Spacing systems

**Created as template, you customize it.**

---

## Commands

### Core Commands

```bash
# Execute with context
tether-cli "your prompt"

# Flags
tether-cli "prompt" --dry-run      # Preview only
tether-cli "prompt" --review       # Review before commit
tether-cli "prompt" --no-commit    # Skip git
tether-cli "prompt" --auto-commit  # Force commit
```

### Git Commands

```bash
tether-cli commit                  # Manual commit
tether-cli diff                    # Show changes
tether-cli rollback                # Soft rollback
tether-cli rollback --hard         # Hard rollback
tether-cli history                 # Show AI commits
```

### Project Commands

```bash
tether-cli detect                  # Detect & create config files
tether-cli status                  # Show status
```

### Update Commands

```bash
tether-cli --update-rules          # Update knowledge base
tether-cli --update-tool           # Update CLI tool
tether-cli --version               # Show version
```

---

## Workflow Examples

### Example 1: New Next.js Project

```bash
# Create project
npx create-next-app@latest my-app
cd my-app

# Detect configuration
tether detect

# Output:
# [+] Created .tether/project.yaml
# [+] Created .tether/design-tokens.md (template)

# Edit your design tokens
vim .tether/design-tokens.md
# (Add your colors, typography, component rules)

# Optionally set design system
vim .tether/project.yaml
# Change: design_system: minimalism

# Start building
tether "create a hero section with CTA button"
```

### Example 2: Existing React Native Project

```bash
cd my-expo-app

# Detect configuration
tether detect

# Auto-detected:
# framework: expo
# styling_foundation: nativewind

# Customize design tokens
vim .tether/design-tokens.md

# Start building
tether "create a profile screen with avatar upload"
```

### Example 3: With Design System

```bash
# Set brutalist design system
vim .tether/project.yaml
# design_system: brutalism

# Define tokens
vim .tether/design-tokens.md
# Colors: Black/white high contrast
# Typography: Heavy, bold fonts
# Components: Thick borders, no shadows

# Build with brutalist style
tether "create a landing page"
# AI will follow brutalist principles + your tokens
```

---

## Creating Your Own Rules

### 1. Fork this Repository

```bash
git clone https://github.com/YOUR_USERNAME/my-tether-rules.git
cd my-tether-rules
```

### 2. Customize

```bash
my-tether-rules/
├── global/
│   └── clean-code.md           # Your standards
│
├── stacks/
│   ├── web/
│   │   └── next-app.md         # Your Next.js conventions
│   │
│   └── mobile/
│       └── expo.md             # Your Expo conventions
│
└── designs/
    ├── systems/
    │   └── company-brand.md    # Your design philosophy
    │
    └── foundations/
        └── tailwind.md         # Your Tailwind patterns
```

### 3. Install with Your Rules

```bash
# Run installer
curl -fsSL https://raw.githubusercontent.com/na-ive/tether-cli/main/install.sh | bash
# Enter your repo URL when prompted
```

---

## Safety Features

### Protected Files

Never auto-committed:

- `.env*`
- `*.key`, `*.pem`
- `secrets.json`, `credentials.json`

### Dry-Run Mode

```bash
tether "refactor auth" --dry-run
```

Shows:

- Files to modify
- Change summary
- Commit message preview
- Detailed diff (optional)

---

## Troubleshooting

### Module Not Found

```bash
curl -fsSL https://raw.githubusercontent.com/na-ive/tether-cli/main/install.sh | bash
```

### Git Not Working

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git init
```

### Design Tokens Not Being Used

Make sure `.tether/design-tokens.md` exists and has content:

```bash
ls .tether/design-tokens.md
cat .tether/design-tokens.md
```

---

## Roadmap

### v1.1

- Interactive wizard
- More design systems
- Preset selector

### v2.0

- Backend/API rules
- Database rules
- State management patterns

### v3.0

- Orchestrator integration
- Team collaboration
- Workspace management

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT License - See [LICENSE](LICENSE)

## Support

- **Issues**: https://github.com/na-ive/tether-cli/issues
- **Discussions**: https://github.com/na-ive/tether-cli/discussions

---

Built for AI-assisted development.
