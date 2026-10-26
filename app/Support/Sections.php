<?php

namespace App\Support;

use App\Models\Experience;
use App\Models\Highlight;
use App\Models\Project;
use App\Models\ResearchTopic;
use App\Models\SkillCategory;
use App\Models\Stat;

/**
 * Describes every repeatable portfolio section. The generic CRUD controller
 * and Blade views are driven entirely by this configuration.
 */
class Sections
{
    public static function all(): array
    {
        return [
            'stats' => [
                'relation' => 'stats', 'model' => Stat::class,
                'label' => 'Hero stats', 'singular' => 'stat', 'icon' => '📈',
                'columns' => ['value' => 'Value', 'label' => 'Label'],
                'fields' => [
                    ['name' => 'value', 'label' => 'Value', 'type' => 'text', 'rules' => 'required|string|max:30', 'help' => 'e.g. .NET'],
                    ['name' => 'label', 'label' => 'Label', 'type' => 'text', 'rules' => 'required|string|max:60', 'help' => 'e.g. Technology'],
                ],
            ],
            'highlights' => [
                'relation' => 'highlights', 'model' => Highlight::class,
                'label' => 'About cards', 'singular' => 'card', 'icon' => '🪪',
                'columns' => ['icon' => 'Icon', 'title' => 'Title', 'subtitle' => 'Subtitle'],
                'fields' => [
                    ['name' => 'icon', 'label' => 'Icon (emoji)', 'type' => 'text', 'rules' => 'nullable|string|max:16'],
                    ['name' => 'title', 'label' => 'Title', 'type' => 'text', 'rules' => 'required|string|max:100'],
                    ['name' => 'subtitle', 'label' => 'Subtitle', 'type' => 'text', 'rules' => 'nullable|string|max:150'],
                ],
            ],
            'experiences' => [
                'relation' => 'experiences', 'model' => Experience::class,
                'label' => 'Experience', 'singular' => 'experience', 'icon' => '💼',
                'columns' => ['date_label' => 'Date', 'title' => 'Title', 'company' => 'Company'],
                'fields' => [
                    ['name' => 'date_label', 'label' => 'Date label', 'type' => 'text', 'rules' => 'nullable|string|max:30', 'help' => 'e.g. CURRENT or 2021 - 2024'],
                    ['name' => 'title', 'label' => 'Job title', 'type' => 'text', 'rules' => 'required|string|max:150'],
                    ['name' => 'company', 'label' => 'Company / organisation', 'type' => 'text', 'rules' => 'nullable|string|max:150'],
                    ['name' => 'details', 'label' => 'Bullet points', 'type' => 'textarea', 'rows' => 6, 'rules' => 'nullable|string|max:3000', 'help' => 'One bullet per line.'],
                ],
            ],
            'skills' => [
                'relation' => 'skillCategories', 'model' => SkillCategory::class,
                'label' => 'Skills', 'singular' => 'skill category', 'icon' => '🛠️',
                'columns' => ['name' => 'Category', 'skills' => 'Skills'],
                'fields' => [
                    ['name' => 'name', 'label' => 'Category name', 'type' => 'text', 'rules' => 'required|string|max:100'],
                    ['name' => 'skills', 'label' => 'Skills', 'type' => 'textarea', 'rows' => 3, 'rules' => 'nullable|string|max:1000', 'help' => 'Comma separated, e.g. C#, C++, PHP'],
                ],
            ],
            'projects' => [
                'relation' => 'projects', 'model' => Project::class,
                'label' => 'Projects', 'singular' => 'project', 'icon' => '🚀',
                'columns' => ['icon' => 'Icon', 'title' => 'Title', 'tags' => 'Tags', 'featured' => 'Featured'],
                'fields' => [
                    ['name' => 'icon', 'label' => 'Icon (emoji)', 'type' => 'text', 'rules' => 'nullable|string|max:16'],
                    ['name' => 'title', 'label' => 'Title', 'type' => 'text', 'rules' => 'required|string|max:150'],
                    ['name' => 'description', 'label' => 'Description', 'type' => 'textarea', 'rows' => 4, 'rules' => 'nullable|string|max:1000'],
                    ['name' => 'tags', 'label' => 'Tags', 'type' => 'text', 'rules' => 'nullable|string|max:500', 'help' => 'Comma separated, e.g. Flutter, Laravel, API'],
                    ['name' => 'link_url', 'label' => 'Link URL', 'type' => 'text', 'rules' => ['nullable', 'string', 'max:500', 'regex:/^(https?:\/\/|#)\S*$/i'], 'help' => 'https://… or an on-page anchor like #contact'],
                    ['name' => 'link_label', 'label' => 'Link label', 'type' => 'text', 'rules' => 'nullable|string|max:60', 'help' => 'Default: View project'],
                    ['name' => 'featured', 'label' => 'Featured project', 'type' => 'checkbox', 'rules' => 'boolean'],
                ],
            ],
            'topics' => [
                'relation' => 'researchTopics', 'model' => ResearchTopic::class,
                'label' => 'Research topics', 'singular' => 'topic', 'icon' => '🔬',
                'columns' => ['name' => 'Topic'],
                'fields' => [
                    ['name' => 'name', 'label' => 'Topic', 'type' => 'text', 'rules' => 'required|string|max:100'],
                ],
            ],
        ];
    }

    public static function get(string $key): ?array
    {
        return self::all()[$key] ?? null;
    }

    /** Regex alternation for route constraints. */
    public static function pattern(): string
    {
        return implode('|', array_keys(self::all()));
    }

    public static function profileFields(): array
    {
        $g = fn (string $group, array $f) => $f + ['group' => $group];

        return [
            $g('Publishing', ['name' => 'is_public', 'label' => 'Publish my portfolio (visible to everyone)', 'type' => 'checkbox', 'rules' => 'boolean']),

            $g('Identity', ['name' => 'full_name', 'label' => 'Full name', 'type' => 'text', 'rules' => 'required|string|max:120']),
            $g('Identity', ['name' => 'role_title', 'label' => 'Role title (hero card)', 'type' => 'text', 'rules' => 'nullable|string|max:150', 'help' => 'e.g. IT Lecturer & Software Developer']),
            $g('Identity', ['name' => 'status_text', 'label' => 'Status text', 'type' => 'text', 'rules' => 'nullable|string|max:150', 'help' => 'e.g. Available for collaboration']),

            $g('Hero', ['name' => 'headline', 'label' => 'Small headline', 'type' => 'text', 'rules' => 'nullable|string|max:150', 'help' => 'e.g. IT LECTURER • DEVELOPER • RESEARCHER']),
            $g('Hero', ['name' => 'hero_line1', 'label' => 'Title – line 1', 'type' => 'text', 'rules' => 'nullable|string|max:150']),
            $g('Hero', ['name' => 'hero_line2', 'label' => 'Title – line 2 (highlighted)', 'type' => 'text', 'rules' => 'nullable|string|max:150']),
            $g('Hero', ['name' => 'hero_text', 'label' => 'Intro text', 'type' => 'textarea', 'rows' => 3, 'rules' => 'nullable|string|max:1000']),
            $g('Hero', ['name' => 'code_items', 'label' => 'Code window items', 'type' => 'text', 'rules' => 'nullable|string|max:250', 'help' => 'Comma separated, e.g. Teaching, Research, Development. Leave empty to hide the code window.']),

            $g('About', ['name' => 'about_title', 'label' => 'Section title', 'type' => 'text', 'rules' => 'nullable|string|max:150']),
            $g('About', ['name' => 'about_text', 'label' => 'About text', 'type' => 'textarea', 'rows' => 8, 'rules' => 'nullable|string|max:5000', 'help' => 'One paragraph per line. Use **double asterisks** for bold.']),

            $g('Section titles', ['name' => 'experience_title', 'label' => 'Experience title', 'type' => 'text', 'rules' => 'nullable|string|max:150']),
            $g('Section titles', ['name' => 'skills_title', 'label' => 'Skills title', 'type' => 'text', 'rules' => 'nullable|string|max:150']),
            $g('Section titles', ['name' => 'projects_title', 'label' => 'Projects title', 'type' => 'text', 'rules' => 'nullable|string|max:150']),

            $g('Research', ['name' => 'research_title', 'label' => 'Research title', 'type' => 'textarea', 'rows' => 2, 'rules' => 'nullable|string|max:200', 'help' => 'A line break creates a second line.']),
            $g('Research', ['name' => 'research_text', 'label' => 'Research text', 'type' => 'textarea', 'rows' => 4, 'rules' => 'nullable|string|max:2000']),

            $g('Contact', ['name' => 'contact_title', 'label' => 'Contact title', 'type' => 'text', 'rules' => 'nullable|string|max:150']),
            $g('Contact', ['name' => 'contact_text', 'label' => 'Contact text', 'type' => 'textarea', 'rows' => 3, 'rules' => 'nullable|string|max:1000']),
            $g('Contact', ['name' => 'email', 'label' => 'Public email', 'type' => 'email', 'rules' => 'nullable|email|max:255']),
            $g('Contact', ['name' => 'linkedin', 'label' => 'LinkedIn URL', 'type' => 'text', 'rules' => 'nullable|url:http,https|max:500']),
            $g('Contact', ['name' => 'github', 'label' => 'GitHub URL', 'type' => 'text', 'rules' => 'nullable|url:http,https|max:500']),

            $g('SEO & footer', ['name' => 'meta_description', 'label' => 'Meta description', 'type' => 'text', 'rules' => 'nullable|string|max:255']),
            $g('SEO & footer', ['name' => 'footer_tagline', 'label' => 'Footer tagline', 'type' => 'text', 'rules' => 'nullable|string|max:200']),
        ];
    }
}
