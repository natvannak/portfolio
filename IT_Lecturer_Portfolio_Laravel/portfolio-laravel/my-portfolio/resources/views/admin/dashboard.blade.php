@extends('admin.layout')
@section('title', 'Dashboard')
@section('content')
<div class="page-head">
  <h1>Dashboard</h1>
  @if($target->username)
    <a class="btn secondary" target="_blank" rel="noopener" href="{{ route('portfolio.show', ['username' => $target->username]) }}">View portfolio ↗</a>
  @endif
</div>

<div class="card">
  <p>
    Portfolio of <b>{{ $target->name }}</b> —
    @if($profile->is_public)
      <span class="pill ok">Published</span>
    @else
      <span class="pill warn">Draft (only you and admins can preview it)</span>
      <a href="{{ route('admin.profile.edit') }}">Publish it in Profile →</a>
    @endif
  </p>
</div>

<div class="stat-grid">
  @foreach($sections as $key => $cfg)
    <a class="stat-card" href="{{ route('admin.section.index', ['section' => $key]) }}">
      <span class="stat-icon">{{ $cfg['icon'] }}</span>
      <strong>{{ $counts[$key] }}</strong>
      <small>{{ $cfg['label'] }}</small>
    </a>
  @endforeach
  @if($userCount !== null)
    <a class="stat-card" href="{{ route('admin.users.index') }}">
      <span class="stat-icon">👥</span>
      <strong>{{ $userCount }}</strong>
      <small>Users</small>
    </a>
  @endif
</div>
@endsection
