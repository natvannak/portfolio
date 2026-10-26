@extends('layouts.guest')
@section('title', 'Create your portfolio')
@section('content')
<form method="POST" action="{{ url('/register') }}" class="form">
  @csrf
  <div class="field">
    <label for="name">Full name</label>
    <input id="name" type="text" name="name" value="{{ old('name') }}" required autofocus>
    @error('name')<span class="error">{{ $message }}</span>@enderror
  </div>
  <div class="field">
    <label for="username">Username</label>
    <input id="username" type="text" name="username" value="{{ old('username') }}" required pattern="[A-Za-z0-9_-]+" autocapitalize="none">
    <small>Your portfolio will live at {{ url('/') }}/<b>username</b></small>
    @error('username')<span class="error">{{ $message }}</span>@enderror
  </div>
  <div class="field">
    <label for="email">Email</label>
    <input id="email" type="email" name="email" value="{{ old('email') }}" required>
    @error('email')<span class="error">{{ $message }}</span>@enderror
  </div>
  <div class="field">
    <label for="password">Password</label>
    <input id="password" type="password" name="password" required autocomplete="new-password">
    @error('password')<span class="error">{{ $message }}</span>@enderror
  </div>
  <div class="field">
    <label for="password_confirmation">Confirm password</label>
    <input id="password_confirmation" type="password" name="password_confirmation" required autocomplete="new-password">
  </div>
  <button class="btn primary block" type="submit">Create account</button>
  <p class="muted center">Already registered? <a href="{{ route('login') }}">Sign in</a></p>
</form>
@endsection
