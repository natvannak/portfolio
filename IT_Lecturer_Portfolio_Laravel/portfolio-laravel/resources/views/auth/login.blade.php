@extends('layouts.guest')
@section('title', 'Sign in')
@section('content')
<form method="POST" action="{{ url('/login') }}" class="form">
  @csrf
  <div class="field">
    <label for="email">Email</label>
    <input id="email" type="email" name="email" value="{{ old('email') }}" required autofocus autocomplete="username">
    @error('email')<span class="error">{{ $message }}</span>@enderror
  </div>
  <div class="field">
    <label for="password">Password</label>
    <input id="password" type="password" name="password" required autocomplete="current-password">
    @error('password')<span class="error">{{ $message }}</span>@enderror
  </div>
  <div class="field field-check">
    <label class="check"><input type="checkbox" name="remember" value="1"> Remember me</label>
  </div>
  <button class="btn primary block" type="submit">Sign in</button>
  @if(config('portfolio.allow_registration'))
    <p class="muted center">No account? <a href="{{ route('register') }}">Create your portfolio</a></p>
  @endif
</form>
@endsection
