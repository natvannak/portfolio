@extends('admin.layout')
@section('title', 'Profile & texts')
@section('content')
<div class="page-head">
  <div>
    <h1>Profile &amp; Texts</h1>
    <p class="page-sub">Identity, hero, about texts, contact details and publishing status.</p>
  </div>
  @if($user->username)
    <div class="page-actions">
      <a class="btn secondary" target="_blank" rel="noopener" href="{{ route('portfolio.show', ['username' => $user->username]) }}"><x-icon name="external-link" /> View Portfolio</a>
    </div>
  @endif
</div>

<form method="POST" action="{{ route('admin.profile.update') }}" enctype="multipart/form-data" class="form">
  @csrf
  @method('PUT')

  <fieldset class="card">
    <legend>Photo</legend>
    <div class="avatar-row">
      @if($profile->avatar)
        <img class="avatar-preview" src="{{ asset('storage/' . $profile->avatar) }}" alt="Current photo">
      @else
        <div class="avatar-preview ph">{{ $profile->initials() }}</div>
      @endif
      <div>
        <input type="file" name="avatar" accept="image/png,image/jpeg,image/webp">
        <small>JPG, PNG or WEBP, max 2 MB.</small>
        @error('avatar')<span class="error">{{ $message }}</span>@enderror
        @if($profile->avatar)
          <label class="check"><input type="hidden" name="remove_avatar" value="0"><input type="checkbox" name="remove_avatar" value="1"> Remove current photo</label>
        @endif
      </div>
    </div>
  </fieldset>

  @foreach($groups as $group => $fields)
    <fieldset class="card">
      <legend>{{ $group }}</legend>
      @foreach($fields as $f)
        @include('admin._field', ['f' => $f, 'model' => $profile])
      @endforeach
    </fieldset>
  @endforeach

  <button class="btn primary" type="submit">Save profile</button>
</form>
@endsection
