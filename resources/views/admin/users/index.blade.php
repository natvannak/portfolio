@extends('admin.layout')
@section('title', 'Users')
@section('content')
<div class="page-head">
  <h1>👥 Users</h1>
  <a class="btn primary" href="{{ route('admin.users.create') }}">+ Add user</a>
</div>

<div class="card table-wrap">
  <table>
    <thead>
      <tr><th>Name</th><th>Username</th><th>Email</th><th>Role</th><th>Status</th><th>Portfolio</th><th class="right">Actions</th></tr>
    </thead>
    <tbody>
      @foreach($users as $u)
      <tr>
        <td>{{ $u->name }}</td>
        <td>&#64;{{ $u->username }}</td>
        <td>{{ $u->email }}</td>
        <td><span class="pill {{ $u->isAdmin() ? 'info' : '' }}">{{ $u->role }}</span></td>
        <td><span class="pill {{ $u->is_active ? 'ok' : 'bad' }}">{{ $u->is_active ? 'Active' : 'Disabled' }}</span></td>
        <td>
          @if($u->profile?->is_public)<span class="pill ok">Published</span>@else<span class="pill warn">Draft</span>@endif
          @if($u->username)<a href="{{ route('portfolio.show', ['username' => $u->username]) }}" target="_blank" rel="noopener">↗</a>@endif
        </td>
        <td class="right actions">
          <form method="POST" action="{{ route('admin.users.manage', $u) }}">@csrf<button class="btn small" type="submit">Manage content</button></form>
          <a class="btn small" href="{{ route('admin.users.edit', $u) }}">Edit</a>
          @unless($u->is(auth()->user()))
          <form method="POST" action="{{ route('admin.users.destroy', $u) }}" onsubmit="return confirm('Delete {{ addslashes($u->name) }} and ALL of their portfolio content?')">
            @csrf
            @method('DELETE')
            <button class="btn small danger" type="submit">Delete</button>
          </form>
          @endunless
        </td>
      </tr>
      @endforeach
    </tbody>
  </table>
</div>
@endsection
