@extends('admin.layout')
@section('title', 'My account')
@section('content')
<div class="page-head"><h1>My account</h1></div>

<form method="POST" action="{{ route('admin.account.update') }}" class="form narrow">
  @csrf
  @method('PUT')
  <div class="card">
    <div class="field">
      <label for="name">Name</label>
      <input id="name" type="text" name="name" value="{{ old('name', $user->name) }}" required>
      @error('name')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="username">Username</label>
      <input id="username" type="text" name="username" value="{{ old('username', $user->username) }}" required>
      <small>Your portfolio URL: {{ url('/') }}/<b>{{ $user->username }}</b></small>
      @error('username')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="email">Login email</label>
      <input id="email" type="email" name="email" value="{{ old('email', $user->email) }}" required>
      @error('email')<span class="error">{{ $message }}</span>@enderror
    </div>
  </div>

  <div class="card">
    <h3>Change password</h3>
    <small>Leave blank to keep the current password.</small>
    <div class="field">
      <label for="current_password">Current password</label>
      <input id="current_password" type="password" name="current_password" autocomplete="current-password">
      @error('current_password')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="password">New password</label>
      <input id="password" type="password" name="password" autocomplete="new-password">
      @error('password')<span class="error">{{ $message }}</span>@enderror
    </div>
    <div class="field">
      <label for="password_confirmation">Confirm new password</label>
      <input id="password_confirmation" type="password" name="password_confirmation" autocomplete="new-password">
    </div>
  </div>
  <button class="btn primary" type="submit">Save account</button>
</form>
@endsection
