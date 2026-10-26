@extends('admin.layout')
@section('title', $user->exists ? 'Edit user' : 'Add user')
@section('content')
<div class="page-head">
  <h1>{{ $user->exists ? 'Edit user' : 'Add user' }}</h1>
  <a class="btn secondary" href="{{ route('admin.users.index') }}">← Back</a>
</div>

<form method="POST" class="form narrow"
      action="{{ $user->exists ? route('admin.users.update', $user) : route('admin.users.store') }}">
  @csrf
  @if($user->exists) @method('PUT') @endif

  <div class="card">
    <div class="field">
      <label for="name">Name</label>
      <input id="name" type="text" name="name" value="{{ old('name', $user->name) }}" required>
      @error('name')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="username">Username</label>
      <input id="username" type="text" name="username" value="{{ old('username', $user->username) }}" required>
      @error('username')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="email">Email</label>
      <input id="email" type="email" name="email" value="{{ old('email', $user->email) }}" required>
      @error('email')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="password">Password {{ $user->exists ? '(leave blank to keep)' : '' }}</label>
      <input id="password" type="password" name="password" autocomplete="new-password" {{ $user->exists ? '' : 'required' }}>
      <small>At least 8 characters.</small>
      @error('password')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="role">Role</label>
      <select id="role" name="role" {{ $isSelf ? 'disabled' : '' }}>
        @foreach(['user' => 'User (own portfolio only)', 'admin' => 'Admin (everything)'] as $val => $label)
          <option value="{{ $val }}" @selected(old('role', $user->role ?: 'user') === $val)>{{ $label }}</option>
        @endforeach
      </select>
      @if($isSelf)<input type="hidden" name="role" value="{{ $user->role }}">@endif
      @error('role')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field field-check">
      <label class="check">
        <input type="hidden" name="is_active" value="0">
        <input type="checkbox" name="is_active" value="1" @checked(old('is_active', $user->exists ? $user->is_active : true)) {{ $isSelf ? 'disabled' : '' }}>
        Account active (can sign in, portfolio visible)
      </label>
      @if($isSelf)<input type="hidden" name="is_active" value="1">@endif
    </div>
    @if($isSelf)<small>You cannot change your own role or disable yourself.</small>@endif
  </div>

  <button class="btn primary" type="submit">{{ $user->exists ? 'Save changes' : 'Create user' }}</button>
</form>
@endsection
