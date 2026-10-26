<?php

namespace App\Http\Controllers;

use App\Support\Portfolio;
use App\Support\Sections;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function edit()
    {
        $user = Portfolio::target();

        return view('admin.profile', [
            'user' => $user,
            'profile' => $user->ensureProfile(),
            'groups' => collect(Sections::profileFields())->groupBy('group'),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $user = Portfolio::target();
        $profile = $user->ensureProfile();

        $rules = [
            'avatar' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
            'remove_avatar' => ['nullable', 'boolean'],
        ];
        foreach (Sections::profileFields() as $f) {
            $rules[$f['name']] = $f['rules'];
        }

        $data = $request->validate($rules);
        unset($data['avatar'], $data['remove_avatar']);

        $disk = Storage::disk('public');

        if ($request->boolean('remove_avatar') && $profile->avatar) {
            $disk->delete($profile->avatar);
            $data['avatar'] = null;
        }

        if ($request->hasFile('avatar')) {
            if ($profile->avatar) {
                $disk->delete($profile->avatar);
            }
            $data['avatar'] = $request->file('avatar')->store('avatars', 'public');
        }

        $profile->update($data);

        return back()->with('status', 'Profile saved.');
    }
}
