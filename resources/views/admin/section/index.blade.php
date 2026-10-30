@extends('admin.layout')
@section('title', $cfg['label'])
@section('content')
<div class="page-head">
  <div>
    <h1><x-icon name="{{ $cfg['icon'] }}" :size="24" /> {{ $cfg['label'] }}</h1>
    <p class="page-sub">Manage every {{ strtolower($cfg['singular']) }} shown on the portfolio section.</p>
  </div>
  <div class="page-actions">
    <a class="btn primary" href="{{ route('admin.section.create', ['section' => $section]) }}">
      <x-icon name="plus" :size="16" /> Add {{ $cfg['singular'] }}
    </a>
  </div>
</div>

<div class="card table-wrap">
  @if($items->isEmpty())
    <div class="empty-state">
      <span class="icon-box"><x-icon name="{{ $cfg['icon'] }}" /></span>
      <b>No {{ strtolower($cfg['label']) }} yet</b>
      <p>Use the “Add {{ $cfg['singular'] }}” button above to create the first one.</p>
    </div>
  @else
    <table>
      <thead>
        <tr>
          <th>Order</th>
          @foreach($cfg['columns'] as $label)<th>{{ $label }}</th>@endforeach
          <th class="right">Actions</th>
        </tr>
      </thead>
      <tbody>
        @foreach($items as $item)
        <tr>
          <td class="cell-muted">{{ $item->sort_order }}</td>
          @foreach($cfg['columns'] as $col => $label)
            <td>
              @if(is_bool($item->{$col}))
                @if($item->{$col})<span class="pill ok"><span class="dot"></span>Yes</span>@else<span class="cell-muted">—</span>@endif
              @else
                {{ \Illuminate\Support\Str::limit((string) $item->{$col}, 70) }}
              @endif
            </td>
          @endforeach
          <td class="right actions">
            <a class="btn small" href="{{ route('admin.section.edit', ['section' => $section, 'id' => $item->id]) }}"><x-icon name="pencil" /> Edit</a>
            <form method="POST" action="{{ route('admin.section.destroy', ['section' => $section, 'id' => $item->id]) }}" onsubmit="return confirm('Delete this {{ $cfg['singular'] }}?')">
              @csrf
              @method('DELETE')
              <button class="btn small danger" type="submit"><x-icon name="trash-2" /> Delete</button>
            </form>
          </td>
        </tr>
        @endforeach
      </tbody>
    </table>
  @endif
</div>
@endsection
