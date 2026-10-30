@extends('admin.layout')
@section('title', ($item->exists ? 'Edit ' : 'Add ') . $cfg['singular'])
@section('content')
<div class="page-head">
  <div>
    <h1>{{ $item->exists ? 'Edit' : 'Add' }} {{ $cfg['singular'] }}</h1>
    <p class="page-sub">{{ $item->exists ? 'Update this ' : 'Create a new ' }}{{ strtolower($cfg['singular']) }} for the {{ strtolower($cfg['label']) }} section.</p>
  </div>
  <div class="page-actions">
    <a class="btn secondary" href="{{ route('admin.section.index', ['section' => $section]) }}"><x-icon name="arrow-left" /> Back</a>
  </div>
</div>

<form method="POST" class="form narrow"
      action="{{ $item->exists
        ? route('admin.section.update', ['section' => $section, 'id' => $item->id])
        : route('admin.section.store', ['section' => $section]) }}">
  @csrf
  @if($item->exists) @method('PUT') @endif

  <div class="card">
    @foreach($cfg['fields'] as $f)
      @include('admin._field', ['f' => $f, 'model' => $item])
    @endforeach

    @include('admin._field', ['model' => $item, 'f' => [
      'name' => 'sort_order', 'label' => 'Display order', 'type' => 'number',
      'help' => 'Lower numbers appear first. Leave empty to add at the end.',
    ]])
  </div>

  <button class="btn primary" type="submit"><x-icon name="{{ $item->exists ? 'pencil' : 'plus' }}" :size="16" /> {{ $item->exists ? 'Save changes' : 'Create' }}</button>
</form>
@endsection
