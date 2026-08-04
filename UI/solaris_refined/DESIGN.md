---
name: Solaris Refined
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#534434'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#867461'
  outline-variant: '#d8c3ad'
  surface-tint: '#855300'
  primary: '#855300'
  on-primary: '#ffffff'
  primary-container: '#f59e0b'
  on-primary-container: '#613b00'
  inverse-primary: '#ffb95f'
  secondary: '#904d00'
  on-secondary: '#ffffff'
  secondary-container: '#fe932c'
  on-secondary-container: '#663500'
  tertiary: '#565e74'
  on-tertiary: '#ffffff'
  tertiary-container: '#a9b0c9'
  on-tertiary-container: '#3b4358'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffddb8'
  primary-fixed-dim: '#ffb95f'
  on-primary-fixed: '#2a1700'
  on-primary-fixed-variant: '#653e00'
  secondary-fixed: '#ffdcc3'
  secondary-fixed-dim: '#ffb77d'
  on-secondary-fixed: '#2f1500'
  on-secondary-fixed-variant: '#6e3900'
  tertiary-fixed: '#dae2fd'
  tertiary-fixed-dim: '#bec6e0'
  on-tertiary-fixed: '#131b2e'
  on-tertiary-fixed-variant: '#3f465c'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-md:
    fontFamily: Work Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Work Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
  container-max: 1280px
---

## Brand & Style

This design system is built for premium financial services and high-end editorial platforms. The brand personality is authoritative yet illuminating, designed to evoke a sense of warmth, precision, and exclusivity. 

The aesthetic follows a **Modern Corporate** style with **Minimalist** leanings. It prioritizes clarity and high-contrast accessibility while utilizing subtle depth to distinguish interactive elements. The interface uses generous whitespace to reduce cognitive load, allowing the vibrant amber accents to guide user attention toward critical actions and data points.

## Colors

The palette is anchored by a hierarchical gold/amber structure. 
- **Primary (#F59E0B):** A vibrant, high-energy gold used for primary call-to-actions, active states, and brand highlights. It is optimized for visibility against light backgrounds.
- **Secondary (#D97706):** A deeper, burnt amber used for secondary actions, hover states of primary elements, and iconography that requires a more grounded presence.
- **Tertiary (#0F172A):** A dark navy used for typography and structural elements to provide a high-contrast anchor to the warm highlights.
- **Neutral (#64748B):** A balanced slate grey for secondary text and borders.

The design system defaults to a **light mode** with a clean white base and cool-toned grey surfaces to allow the warm primary colors to "pop" effectively.

## Typography

The typography system balances modern geometry with professional utility. 
- **Manrope** is used for headlines to provide a refined, contemporary look with excellent legibility at large scales.
- **Work Sans** serves as the body face, offering a grounded and reliable reading experience for long-form content and data.
- **JetBrains Mono** is utilized for labels, captions, and technical metadata to introduce a sense of precision and technical sophistication.

Scale headlines down for mobile devices using the provided mobile tokens to ensure text remains within the viewport comfortably.

## Layout & Spacing

The design system employs a **Fixed Grid** model for desktop and a **Fluid Grid** for mobile devices. 
- **Desktop:** 12-column layout, 1280px max-width, 24px gutters.
- **Tablet:** 8-column layout, fluid width, 24px gutters.
- **Mobile:** 4-column layout, fluid width, 16px margins.

Spacing follows a base-4 scale. Use `unit` multiples (4, 8, 16, 24, 32, 48, 64) to maintain rhythmic consistency across all components and sections.

## Elevation & Depth

This design system uses **Tonal Layers** supplemented by **Ambient Shadows** to communicate hierarchy. 
- **Level 0 (Base):** White background (#FFFFFF).
- **Level 1 (Surface):** Light grey container (#F8FAFC) used for cards and grouped content.
- **Level 2 (Raised):** Used for interactive elements (Buttons, Inputs). These feature a very soft, high-diffusion shadow with a slight amber tint (4% opacity of the Secondary color) to suggest a subtle lift.
- **Level 3 (Overlay):** Used for modals and dropdowns. These utilize a larger blur radius (24px) and a neutral slate shadow to clearly separate the element from the main content flow.

## Shapes

The shape language is **Rounded**, strike a balance between friendly approachability and corporate structure. 
- Standard components (buttons, inputs) use a **0.5rem (8px)** corner radius.
- Larger containers and cards use **rounded-lg (16px)** to soften the layout.
- Icons and small badges utilize **rounded-xl (24px)** or full pills for distinct visual differentiation.

## Components

- **Buttons:** Primary buttons use the Primary Gold (#F59E0B) with white text. Secondary buttons use a transparent background with a Secondary Gold (#D97706) border and text. Hover states should darken the background color by 10%.
- **Input Fields:** Use a 1px border (#CBD5E1). On focus, the border shifts to Primary Gold with a 2px stroke.
- **Chips:** Small, pill-shaped indicators. Use a light amber wash (10% opacity of Primary Gold) with Secondary Gold text for high legibility.
- **Cards:** White background, 1px subtle border (#F1F5F9), and Level 1 elevation (subtle shadow).
- **Checkboxes/Radios:** Use Primary Gold for the "Checked" state. Use a thick 2px stroke to ensure the vibrant color is distinct.
- **Progress Bars:** Backgrounds should be the Neutral color at 20% opacity, with the progress fill using the Primary Gold for maximum visibility.