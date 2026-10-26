<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->boolean('is_public')->default(false);
            $table->string('full_name');
            $table->string('headline')->nullable();
            $table->string('hero_line1')->nullable();
            $table->string('hero_line2')->nullable();
            $table->text('hero_text')->nullable();
            $table->string('role_title')->nullable();
            $table->string('status_text')->nullable();
            $table->string('code_items')->nullable();
            $table->string('avatar')->nullable();
            $table->string('about_title')->nullable();
            $table->text('about_text')->nullable();
            $table->string('experience_title')->nullable();
            $table->string('skills_title')->nullable();
            $table->string('projects_title')->nullable();
            $table->string('research_title')->nullable();
            $table->text('research_text')->nullable();
            $table->string('contact_title')->nullable();
            $table->text('contact_text')->nullable();
            $table->string('email')->nullable();
            $table->string('linkedin', 500)->nullable();
            $table->string('github', 500)->nullable();
            $table->string('meta_description')->nullable();
            $table->string('footer_tagline')->nullable();
            $table->timestamps();
        });

        Schema::create('stats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('value', 30);
            $table->string('label', 60);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('highlights', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('icon', 16)->nullable();
            $table->string('title', 100);
            $table->string('subtitle', 150)->nullable();
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('experiences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('date_label', 30)->nullable();
            $table->string('title', 150);
            $table->string('company', 150)->nullable();
            $table->text('details')->nullable();
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('skill_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name', 100);
            $table->text('skills')->nullable();
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('icon', 16)->nullable();
            $table->string('title', 150);
            $table->text('description')->nullable();
            $table->string('tags', 500)->nullable();
            $table->string('link_url', 500)->nullable();
            $table->string('link_label', 60)->nullable();
            $table->boolean('featured')->default(false);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('research_topics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name', 100);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['research_topics', 'projects', 'skill_categories', 'experiences', 'highlights', 'stats', 'profiles'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};
