<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>@yield('title') — {{ config('app.name') }}</title>
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>
<body class="guest">
  <div class="guest-box">
    <a href="{{ route('home') }}" class="logo"><span class="logo-mark">{{ mb_strtoupper(mb_substr(config('app.name'), 0, 1)) }}</span>{{ config('app.name') }}<i class="logo-tail"> Portfolio</i></a>
    <h1>@yield('title')</h1>
    @if(session('status'))<div class="alert ok">{{ session('status') }}</div>@endif
    @yield('content')
  </div>
</body>
</html>
