// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://seleznovivan.github.io',
	base: '/claude-code-course',
	integrations: [
		starlight({
			title: 'Claude Code Course',
			description: 'Learn Claude Code by DOING Claude Code — An interactive 5-module course taught inside Claude Code itself.',
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/SeleznovIvan/claude-code-course-plugin' },
				{ icon: 'linkedin', label: 'LinkedIn', href: 'https://www.linkedin.com/in/ivan-seleznov-phd-65710213a/' },
			],
			head: [
				{
					tag: 'script',
					attrs: { type: 'application/ld+json' },
					content: JSON.stringify({
						'@context': 'https://schema.org',
						'@type': 'Course',
						name: 'Claude Code Developer Course',
						description: 'Interactive 5-module course teaching software developers how to use Claude Code effectively. Work on your own repository, build real configurations.',
						provider: { '@type': 'Person', name: 'Ivan Seleznov' },
						educationalLevel: 'Intermediate',
						timeRequired: 'PT10H',
						isAccessibleForFree: true,
						inLanguage: 'en',
						teaches: [
							'Claude Code CLI and configuration',
							'CLAUDE.md project memory',
							'Custom skills and commands',
							'Hooks and MCP servers',
							'Multi-agent patterns with git worktrees',
							'GitHub Actions and automation scripts',
						],
					}),
				},
			],
			customCss: ['./src/styles/custom.css'],
			sidebar: [
				{ label: 'Home', slug: '' },
				{ label: 'Getting Started', slug: 'getting-started' },
				{ label: 'Commands', slug: 'commands' },
				{
					label: 'Modules',
					items: [
						{ label: '1. Foundations & Commands', slug: 'modules/1-foundations' },
						{ label: '2. Skills', slug: 'modules/2-skills' },
						{ label: '3. Extensions', slug: 'modules/3-extensions' },
						{ label: '4. Agents', slug: 'modules/4-agents' },
						{ label: '5. Workflows', slug: 'modules/5-workflows' },
					],
				},
			],
		}),
	],
});
