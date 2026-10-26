@php
  $me = auth()->user();
  $target = \App\Support\Portfolio::target();
  $managing = $target->id !== $me->id;
  $sectionList = \App\Support\Sections::all();
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>@yield('title', 'Dashboard') — {{ config('app.name') }}</title>
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>
<body class="admin">
  <aside class="sidebar">
    <a href="{{ route('admin.dashboard') }}" class="logo">&lt;{{ config('app.name') }}<span>/&gt;</span></a>

    <nav>
      <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">🏠 Dashboard</a>
      <a href="{{ route('admin.profile.edit') }}" class="{{ request()->routeIs('admin.profile.*') ? 'active' : '' }}">👤 Profile & texts</a>

      <p class="nav-label">Content</p>
      @foreach($sectionList as $key => $cfg)
        <a href="{{ route('admin.section.index', ['section' => $key]) }}"
           class="{{ request()->is('admin/s/' . $key . '*') ? 'active' : '' }}">{{ $cfg['icon'] }} {{ $cfg['label'] }}</a>
      @endforeach

      @if($me->isAdmin())
        <p class="nav-label">Administration</p>
        <a href="{{ route('admin.users.index') }}" class="{{ request()->routeIs('admin.users.*') ? 'active' : '' }}">👥 Users</a>
      @endif

      <p class="nav-label">Account</p>
      <a href="{{ route('admin.account.edit') }}" class="{{ request()->routeIs('admin.account.*') ? 'active' : '' }}">⚙️ My account</a>
      @if($target->username)
        <a href="{{ route('portfolio.show', ['username' => $target->username]) }}" target="_blank" rel="noopener">🌐 View portfolio ↗</a>
      @endif
    </nav>

    <form method="POST" action="{{ route('logout') }}" class="logout">
      @csrf
      <button type="submit" class="btn secondary block">Sign out ({{ $me->name }})</button>
    </form>
  </aside>

  <div class="main">
    @if($managing)
      <div class="manage-bar">
        <span>Managing <b>{{ $target->name }}</b> (&#64;{{ $target->username }})</span>
        <form method="POST" action="{{ route('admin.manage.stop') }}">@csrf <button class="btn secondary" type="submit">Back to my own</button></form>
      </div>
    @endif

    <div class="content">
      @if(session('status'))<div class="alert ok">{{ session('status') }}</div>@endif
      @if(session('error'))<div class="alert bad">{{ session('error') }}</div>@endif
      @if($errors->any())<div class="alert bad">Please fix the highlighted fields.</div>@endif

      @yield('content')
    </div>
  </div>
</body>
</html>
