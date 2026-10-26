@use('App\Support\Text')
@php
  $hasAbout = $p->about_text || $user->highlights->isNotEmpty();
  $hasExp = $user->experiences->isNotEmpty();
  $hasSkills = $user->skillCategories->isNotEmpty();
  $hasProjects = $user->projects->isNotEmpty();
  $hasResearch = $p->research_text || $user->researchTopics->isNotEmpty();
  $hasContact = $p->email || $p->linkedin || $p->github;
  $codeItems = Text::csv($p->code_items);
  $codeLines = implode(",\n", array_map(fn ($i) => '  "' . e($i) . '"', $codeItems));
  $n = 0;
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="{{ $p->meta_description ?: $p->headline }}">
  <title>{{ $p->full_name }}@if($p->role_title) | {{ $p->role_title }}@endif</title>
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
</head>
<body>
  <header class="header">
    <nav class="nav container">
      <a href="#home" class="logo">&lt;{{ $p->initials() }}<span>/&gt;</span></a>
      <button class="menu-btn" id="menuBtn" aria-label="Open menu">☰</button>
      <div class="nav-links" id="navLinks">
        <a href="#home">Home</a>
        @if($hasAbout)<a href="#about">About</a>@endif
        @if($hasExp)<a href="#experience">Experience</a>@endif
        @if($hasSkills)<a href="#skills">Skills</a>@endif
        @if($hasProjects)<a href="#projects">Projects</a>@endif
        @if($hasResearch)<a href="#research">Research</a>@endif
        @if($hasContact)<a href="#contact" class="nav-contact">Contact</a>@endif
      </div>
      <button class="theme-btn" id="themeBtn" aria-label="Toggle theme">☾</button>
    </nav>
  </header>

  <main>
    <section class="hero container" id="home">
      <div class="hero-content reveal">
        @if($p->headline)<p class="eyebrow">{{ $p->headline }}</p>@endif
        <h1>{{ $p->hero_line1 }}@if($p->hero_line2)<br><span>{{ $p->hero_line2 }}</span>@endif</h1>
        @if($p->hero_text)<p class="hero-text">{{ $p->hero_text }}</p>@endif
        <div class="hero-actions">
          @if($hasProjects)<a href="#projects" class="btn primary">View Projects →</a>@endif
          @if($hasContact)<a href="#contact" class="btn secondary">Contact Me</a>@endif
        </div>
        @if($user->stats->isNotEmpty())
        <div class="quick-stats">
          @foreach($user->stats as $stat)
          <div><strong>{{ $stat->value }}</strong><span>{{ $stat->label }}</span></div>
          @endforeach
        </div>
        @endif
      </div>

      <div class="hero-card reveal">
        <div class="avatar">
          <div class="avatar-ring"></div>
          @if($p->avatar)
            <img src="{{ asset('storage/' . $p->avatar) }}" alt="{{ $p->full_name }}">
          @else
            <div class="avatar-initial">{{ $p->initials() }}</div>
          @endif
        </div>
        @if($p->status_text)<div class="status"><i></i> {{ $p->status_text }}</div>@endif
        <h3>{{ $p->full_name }}</h3>
        @if($p->role_title)<p>{{ $p->role_title }}</p>@endif
        @if(count($codeItems))
        <div class="code-window">
          <div class="code-top"><span></span><span></span><span></span></div>
          <pre><code><b>const</b> passion = [
{!! $codeLines !!}
];

<span class="purple">while</span> (learning) {
  build();
  improve();
}</code></pre>
        </div>
        @endif
      </div>
    </section>

    @if($hasAbout)
    <section class="section container" id="about">
      <div class="section-heading reveal">
        <p class="eyebrow">{{ sprintf('%02d', ++$n) }} — ABOUT ME</p>
        @if($p->about_title)<h2>{{ $p->about_title }}</h2>@endif
      </div>
      <div class="about-grid">
        <div class="about-text reveal">
          @foreach(Text::lines($p->about_text) as $paragraph)
            <p>{{ Text::inline($paragraph) }}</p>
          @endforeach
        </div>
        <div class="about-cards reveal">
          @foreach($user->highlights as $card)
          <div class="info-card"><span>{{ $card->icon }}</span><b>{{ $card->title }}</b><small>{{ $card->subtitle }}</small></div>
          @endforeach
        </div>
      </div>
    </section>
    @endif

    @if($hasExp)
    <section class="section section-alt" id="experience">
      <div class="container">
        <div class="section-heading reveal">
          <p class="eyebrow">{{ sprintf('%02d', ++$n) }} — EXPERIENCE</p>
          @if($p->experience_title)<h2>{{ $p->experience_title }}</h2>@endif
        </div>
        <div class="timeline">
          @foreach($user->experiences as $exp)
          <article class="timeline-item reveal">
            <div class="timeline-dot"></div>
            <div class="timeline-date">{{ $exp->date_label }}</div>
            <div class="timeline-content">
              <h3>{{ $exp->title }}</h3>
              @if($exp->company)<p class="company">{{ $exp->company }}</p>@endif
              @if($exp->details)
              <ul>
                @foreach(Text::lines($exp->details) as $bullet)
                <li>{{ $bullet }}</li>
                @endforeach
              </ul>
              @endif
            </div>
          </article>
          @endforeach
        </div>
      </div>
    </section>
    @endif

    @if($hasSkills)
    <section class="section container" id="skills">
      <div class="section-heading reveal">
        <p class="eyebrow">{{ sprintf('%02d', ++$n) }} — SKILLS</p>
        @if($p->skills_title)<h2>{{ $p->skills_title }}</h2>@endif
      </div>
      <div class="skills-grid">
        @foreach($user->skillCategories as $cat)
        <div class="skill-category reveal">
          <h3>{{ $cat->name }}</h3>
          <div class="skill-list">
            @foreach(Text::csv($cat->skills) as $skill)<span>{{ $skill }}</span>@endforeach
          </div>
        </div>
        @endforeach
      </div>
    </section>
    @endif

    @if($hasProjects)
    <section class="section section-alt" id="projects">
      <div class="container">
        <div class="section-heading reveal">
          <p class="eyebrow">{{ sprintf('%02d', ++$n) }} — PROJECTS</p>
          @if($p->projects_title)<h2>{{ $p->projects_title }}</h2>@endif
        </div>
        <div class="project-grid">
          @foreach($user->projects as $project)
          <article class="project-card {{ $project->featured ? 'featured' : '' }} reveal">
            <div class="project-number">{{ sprintf('%02d', $loop->iteration) }}</div>
            @if($project->icon)<div class="project-icon">{{ $project->icon }}</div>@endif
            <h3>{{ $project->title }}</h3>
            <p>{{ $project->description }}</p>
            <div class="tags">
              @foreach(Text::csv($project->tags) as $tag)<span>{{ $tag }}</span>@endforeach
            </div>
            @if($project->link_url)
              @php $external = str_starts_with($project->link_url, 'http'); @endphp
              <a href="{{ $project->link_url }}" @if($external) target="_blank" rel="noopener noreferrer" @endif>{{ $project->link_label ?: 'View project' }} →</a>
            @endif
          </article>
          @endforeach
        </div>
      </div>
    </section>
    @endif

    @if($hasResearch)
    <section class="section container" id="research">
      <div class="research-box reveal">
        <div>
          <p class="eyebrow">{{ sprintf('%02d', ++$n) }} — RESEARCH & LEARNING</p>
          @if($p->research_title)<h2>{!! nl2br(e($p->research_title)) !!}</h2>@endif
          @if($p->research_text)<p>{{ $p->research_text }}</p>@endif
        </div>
        <div class="research-topics">
          @foreach($user->researchTopics as $topic)<span>{{ $topic->name }}</span>@endforeach
        </div>
      </div>
    </section>
    @endif

    @if($hasContact)
    <section class="section section-alt" id="contact">
      <div class="container contact-section reveal">
        <p class="eyebrow">{{ sprintf('%02d', ++$n) }} — CONTACT</p>
        @if($p->contact_title)<h2>{{ $p->contact_title }}</h2>@endif
        @if($p->contact_text)<p>{{ $p->contact_text }}</p>@endif
        @if($p->email)<a class="btn primary" href="mailto:{{ $p->email }}">Email Me →</a>@endif
        <div class="contact-links">
          @if($p->email)<a href="mailto:{{ $p->email }}">Email</a>@endif
          @if($p->linkedin)<a href="{{ $p->linkedin }}" target="_blank" rel="noopener noreferrer">LinkedIn</a>@endif
          @if($p->github)<a href="{{ $p->github }}" target="_blank" rel="noopener noreferrer">GitHub</a>@endif
        </div>
      </div>
    </section>
    @endif
  </main>

  <footer>
    <div class="container footer-inner">
      <span>© <span id="year">{{ date('Y') }}</span> {{ $p->full_name }}</span>
      <span>{{ $p->footer_tagline }}</span>
    </div>
  </footer>

  @unless($p->is_public)
    <div class="draft-banner">Draft preview — not visible to the public</div>
  @endunless

  <script src="{{ asset('js/script.js') }}"></script>
</body>
</html>
