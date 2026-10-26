@php
  $name = $f['name'];
  $type = $f['type'] ?? 'text';
  $value = old($name, $model->{$name} ?? ($f['default'] ?? ''));
@endphp
<div class="field {{ $type === 'checkbox' ? 'field-check' : '' }}">
  @if($type === 'checkbox')
    <label class="check">
      <input type="hidden" name="{{ $name }}" value="0">
      <input type="checkbox" id="f-{{ $name }}" name="{{ $name }}" value="1" @checked((bool) $value)>
      {{ $f['label'] }}
    </label>
  @else
    <label for="f-{{ $name }}">{{ $f['label'] }}</label>
    @if($type === 'textarea')
      <textarea id="f-{{ $name }}" name="{{ $name }}" rows="{{ $f['rows'] ?? 4 }}">{{ $value }}</textarea>
    @else
      <input id="f-{{ $name }}" type="{{ $type }}" name="{{ $name }}" value="{{ $value }}">
    @endif
  @endif
  @if(!empty($f['help']))<small>{{ $f['help'] }}</small>@endif
  @error($name)<span class="error">{{ $message }}</span>@enderror
</div>
