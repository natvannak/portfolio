@extends('admin.layout')
@section('title', 'Dashboard')

@php
  /* Brand accent mapping — Deep Red and Blue Balance */
  $cardMeta = [
    'stats'       => ['icon' => 'chart-no-axes-combined', 'tint' => 'steel',    'desc' => 'Hero section indicators'],
    'highlights'  => ['icon' => 'id-card',                'tint' => 'wine',     'desc' => 'About section cards'],
    'experiences' => ['icon' => 'briefcase-business',     'tint' => 'indian',   'desc' => 'Career history entries'],
    'skills'      => ['icon' => 'wrench',                 'tint' => 'steel',    'desc' => 'Skill categories'],
    'projects'    => ['icon' => 'rocket',                 'tint' => 'burgundy', 'desc' => 'Showcase projects'],
    'topics'      => ['icon' => 'microscope',             'tint' => 'midnight', 'desc' => 'Research interests'],
  ];
  $published = (bool) $profile->is_public;
@endphp
@section('content')
<div class="page-head">
  <div>
    <h1>Dashboard</h1>
    <p class="page-sub">Welcome back. Here's your portfolio overview.</p>
  </div>
  <div class="page-actions">
    @if($target->username)
      <a class="btn secondary" target="_blank" rel="noopener" href="{{ route('portfolio.show', ['username' => $target->username]) }}">
        <x-icon name="external-link" /> View Portfolio
      </a>
    @endif
  </div>
</div>

<div class="publish-banner {{ $published ? 'ok' : 'draft' }}">
  <span class="icon-box">
    <x-icon name="{{ $published ? 'circle-check' : 'triangle-alert' }}" />
  </span>
  <div class="publish-info">
    <span class="publish-title">
      Portfolio of {{ $target->name }}
      <span class="pill {{ $published ? 'ok' : 'warn' }}"><span class="dot"></span>{{ $published ? 'Published' : 'Draft' }}</span>
    </span>
    <p>{{ $published
          ? 'This portfolio is live and visible to everyone.'
          : 'Only you and administrators can preview this portfolio.' }}</p>
  </div>
  @if(!$published)
    <a class="btn secondary" href="{{ route('admin.profile.edit') }}">Publish in Profile</a>
  @endif
</div>

<div class="stat-grid">
  @foreach($sections as $key => $cfg)
    <a class="stat-card" href="{{ route('admin.section.index', ['section' => $key]) }}">
      <span class="top">
        <span class="label">{{ $cfg['label'] }}</span>
        <span class="icon-box {{ $cardMeta[$key]['tint'] ?? 'steel' }}">
          <x-icon name="{{ $cardMeta[$key]['icon'] ?? $cfg['icon'] }}" />
        </span>
      </span>
      <strong>{{ number_format($counts[$key]) }}</strong>
      <small>{{ $cardMeta[$key]['desc'] ?? $cfg['label'] }}</small>
    </a>
  @endforeach
  @if($userCount !== null)
    <a class="stat-card" href="{{ route('admin.users.index') }}">
      <span class="top">
        <span class="label">Users</span>
        <span class="icon-box navy"><x-icon name="users-round" /></span>
      </span>
      <strong>{{ number_format($userCount) }}</strong>
      <small>Registered accounts</small>
    </a>
  @endif
</div>
@endsection
