@extends('admin.layout')
@section('title', 'Users')
@section('content')
<div class="page-head">
  <div>
    <h1>Users</h1>
    <p class="page-sub">Manage accounts, roles and portfolio ownership.</p>
  </div>
  <div class="page-actions">
    <a class="btn primary" href="{{ route('admin.users.create') }}"><x-icon name="plus" :size="16" /> Add user</a>
  </div>
</div>

<div class="card table-wrap">
  @if($users->isEmpty())
    <div class="empty-state">
      <span class="icon-box"><x-icon name="users-round" /></span>
      <b>No users yet</b>
      <p>Click “Add user” to invite the first account.</p>
    </div>
  @else
    <table>
      <thead>
        <tr><th>Name</th><th>Username</th><th>Email</th><th>Role</th><th>Status</th><th>Portfolio</th><th class="right">Actions</th></tr>
      </thead>
      <tbody>
        @foreach($users as $u)
        <tr>
          <td><b style="font-weight:600">{{ $u->name }}</b></td>
          <td>&#64;{{ $u->username }}</td>
          <td class="cell-muted">{{ $u->email }}</td>
          <td><span class="pill {{ $u->isAdmin() ? 'info' : '' }}"><span class="dot"></span>{{ $u->role }}</span></td>
          <td><span class="pill {{ $u->is_active ? 'ok' : 'bad' }}"><span class="dot"></span>{{ $u->is_active ? 'Active' : 'Disabled' }}</span></td>
          <td>
            @if($u->profile?->is_public)<span class="pill ok">Published</span>@else<span class="pill warn">Draft</span>@endif
            @if($u->username)<a href="{{ route('portfolio.show', ['username' => $u->username]) }}" target="_blank" rel="noopener" class="pill info" style="margin-left:6px"><x-icon name="external-link" :size="12" /> Open</a>@endif
          </td>
          <td class="right actions">
            <form method="POST" action="{{ route('admin.users.manage', $u) }}">@csrf<button class="btn small" type="submit">Manage content</button></form>
            <a class="btn small" href="{{ route('admin.users.edit', $u) }}"><x-icon name="pencil" /> Edit</a>
            @unless($u->is(auth()->user()))
            <form method="POST" action="{{ route('admin.users.destroy', $u) }}" onsubmit="return confirm('Delete {{ addslashes($u->name) }} and ALL of their portfolio content?')">
              @csrf
              @method('DELETE')
              <button class="btn small danger" type="submit"><x-icon name="trash-2" /> Delete</button>
            </form>
            @endunless
          </td>
        </tr>
        @endforeach
      </tbody>
    </table>
  @endif
</div>
@endsection
