<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $password = config('portfolio.admin_password');

        // 1) Administrator ---------------------------------------------------
        if (!User::where('email', config('portfolio.admin_email'))->exists()) {
            $admin = new User([
                'name' => config('portfolio.admin_name'),
                'username' => 'admin-user',
                'email' => config('portfolio.admin_email'),
                'password' => $password,
            ]);
            $admin->role = 'admin';
            $admin->is_active = true;
            $admin->save();
        }

        // 2) The original HTML portfolio (Nat Vannak) as a demo user -----------
        if (User::where('username', 'natvannak')->exists()) {
            return;
        }

        $user = new User([
            'name' => 'Nat Vannak',
            'username' => 'natvannak',
            'email' => 'natvannak@example.com',
            'password' => $password,
        ]);
        $user->role = 'user';
        $user->is_active = true;
        $user->save();

        $user->profile->update([
            'is_public' => true,
            'full_name' => 'Nat Vannak',
            'headline' => 'IT LECTURER • DEVELOPER • RESEARCHER',
            'hero_line1' => 'Building technology.',
            'hero_line2' => 'Teaching the future.',
            'hero_text' => 'IT educator and software developer passionate about teaching, research, system development, and learning emerging technologies.',
            'role_title' => 'IT Lecturer & Software Developer',
            'status_text' => 'Available for collaboration',
            'code_items' => 'Teaching, Research, Development',
            'about_title' => 'Technology with a purpose.',
            'about_text' => implode("\n", [
                'I am currently teaching IT at the **University of South-East Asia**, where I am responsible for **.NET Technology** and **C++ Programming** subjects.',
                'I am also pursuing a **Master’s degree in Information Technology**. My interests include software development, database systems, education technology, research, and continuous self-learning.',
                'I enjoy adapting to new technologies and transforming technical knowledge into practical learning experiences for students.',
            ]),
            'experience_title' => 'Teaching & professional journey.',
            'skills_title' => 'Tools I work with.',
            'projects_title' => 'Selected work.',
            'research_title' => "Always learning.\nAlways experimenting.",
            'research_text' => 'Interested in practical research at the intersection of software engineering, education technology, databases, AI, and emerging technologies.',
            'contact_title' => 'Let’s build something useful.',
            'contact_text' => 'Interested in collaboration, research, teaching, or software projects?',
            'email' => 'your.email@example.com',
            'meta_description' => 'Modern IT Lecturer, Developer and Researcher Portfolio',
            'footer_tagline' => 'IT Lecturer • Developer • Researcher',
        ]);

        $rows = fn (array $list) => collect($list)->values()->map(fn ($r, $i) => $r + ['sort_order' => $i + 1])->all();

        $user->stats()->createMany($rows([
            ['value' => 'IT', 'label' => 'Lecturer'],
            ['value' => '.NET', 'label' => 'Technology'],
            ['value' => 'C++', 'label' => 'Programming'],
        ]));

        $user->highlights()->createMany($rows([
            ['icon' => '🎓', 'title' => 'Master’s Student', 'subtitle' => 'Information Technology'],
            ['icon' => '👨‍🏫', 'title' => 'University Lecturer', 'subtitle' => 'IT Major'],
            ['icon' => '💻', 'title' => 'Software Developer', 'subtitle' => 'Full-stack & Desktop'],
            ['icon' => '🔬', 'title' => 'Researcher', 'subtitle' => 'Technology & Education'],
        ]));

        $user->experiences()->createMany($rows([
            [
                'date_label' => 'CURRENT',
                'title' => 'IT Lecturer / Teacher',
                'company' => 'University of South-East Asia',
                'details' => implode("\n", [
                    'Teach .NET Technology and C++ Programming for IT students.',
                    'Prepare lectures, exercises, programming examples, and practical activities.',
                    'Guide students through programming, database, and software development concepts.',
                    'Develop and improve teaching materials and core study resources.',
                ]),
            ],
            [
                'date_label' => 'PREVIOUS',
                'title' => 'IT / Developer / Database Role',
                'company' => 'Future Bright International School',
                'details' => implode("\n", [
                    'Develop and maintain internal information systems.',
                    'Manage databases, servers, computers, and network infrastructure.',
                    'Provide technical troubleshooting and IT support.',
                    'Research and implement software solutions for organizational needs.',
                ]),
            ],
        ]));

        $user->skillCategories()->createMany($rows([
            ['name' => 'Programming', 'skills' => 'C#, C++, PHP, Java, Kotlin, Python'],
            ['name' => 'Web & Frameworks', 'skills' => '.NET, ASP.NET Core, Laravel, Flutter, Spring Boot'],
            ['name' => 'Database & DevOps', 'skills' => 'MySQL, SQL, Docker, AWS, Git, Linux'],
            ['name' => 'Professional', 'skills' => 'Teaching, Research, Problem Solving, Self-Learning, Teamwork'],
        ]));

        $user->projects()->createMany($rows([
            [
                'icon' => '📊', 'title' => 'Training Management System', 'featured' => true,
                'description' => 'A management platform for organizing training programs, participants, schedules, and reporting.',
                'tags' => 'ASP.NET, MySQL, Agile', 'link_url' => '#contact', 'link_label' => 'View project',
            ],
            [
                'icon' => '📱', 'title' => 'Attendance System',
                'description' => 'Mobile attendance solution using QR verification, geofencing, authentication, and API services.',
                'tags' => 'Flutter, Laravel, API', 'link_url' => '#contact', 'link_label' => 'View project',
            ],
            [
                'icon' => '🧠', 'title' => 'Khmer OCR Research',
                'description' => 'Exploring computer vision and custom CNN models for Khmer character recognition.',
                'tags' => 'Python, CNN, AI', 'link_url' => '#research', 'link_label' => 'Research',
            ],
            [
                'icon' => '☁️', 'title' => 'Cloud & DevOps Lab',
                'description' => 'Hands-on experiments with AWS, Docker, Linux, Terraform, CI/CD, and cloud infrastructure.',
                'tags' => 'AWS, Docker, Terraform', 'link_url' => '#contact', 'link_label' => 'View project',
            ],
        ]));

        $user->researchTopics()->createMany($rows([
            ['name' => 'Artificial Intelligence'],
            ['name' => 'Education Technology'],
            ['name' => 'Software Engineering'],
            ['name' => 'Database Systems'],
            ['name' => 'Cloud Computing'],
            ['name' => 'IoT & Blockchain'],
        ]));
    }
}
