<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Support\Rules;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

/** Admin-only user management (full CRUD). */
class UserController extends Controller
{
    public function index()
    {
        $users = User::with('profile')->orderBy('name')->get();

        return view('admin.users.index', compact('users'));
    }

    public function create()
    {
        return view('admin.users.form', ['user' => new User(['name' => '', 'username' => '', 'email' => '']), 'isSelf' => false]);
    }

    public function store(Request $request): RedirectResponse
    {
        $request->merge(['username' => strtolower((string) $request->input('username'))]);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'username' => Rules::username(),
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', Password::min(8)],
            'role' => ['required', Rule::in(['admin', 'user'])],
            'is_active' => ['required', 'boolean'],
        ]);

        $user = new User(collect($data)->only(['name', 'username', 'email', 'password'])->all());
        $user->role = $data['role'];
        $user->is_active = (bool) $data['is_active'];
        $user->save();

        return redirect()->route('admin.users.index')->with('status', 'User created.');
    }

    public function edit(User $user)
    {
        return view('admin.users.form', ['user' => $user, 'isSelf' => $user->is(auth()->user())]);
    }

    public function update(Request $request, User $user): RedirectResponse
    {
        $request->merge(['username' => strtolower((string) $request->input('username'))]);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'username' => Rules::username($user->id),
            'email' => ['required', 'email', 'max:255', 'unique:users,email,' . $user->id],
            'password' => ['nullable', Password::min(8)],
            'role' => ['required', Rule::in(['admin', 'user'])],
            'is_active' => ['required', 'boolean'],
        ]);

        $user->name = $data['name'];
        $user->username = $data['username'];
        $user->email = $data['email'];
        if (!empty($data['password'])) {
            $user->password = $data['password'];
        }

        // Admins cannot demote or disable themselves (prevents lock-out).
        if (!$user->is(auth()->user())) {
            $user->role = $data['role'];
            $user->is_active = (bool) $data['is_active'];
        }
        $user->save();

        return redirect()->route('admin.users.index')->with('status', 'User updated.');
    }

    public function destroy(User $user): RedirectResponse
    {
        if ($user->is(auth()->user())) {
            return back()->with('error', 'You cannot delete your own account.');
        }

        if ($user->profile?->avatar) {
            Storage::disk('public')->delete($user->profile->avatar);
        }
        if ((int) session('managing_user_id') === $user->id) {
            session()->forget('managing_user_id');
        }
        $user->delete(); // content rows are removed by cascading foreign keys

        return redirect()->route('admin.users.index')->with('status', 'User deleted.');
    }

    /** Let an admin edit another user's portfolio content. */
    public function manage(User $user): RedirectResponse
    {
        session(['managing_user_id' => $user->id]);

        return redirect()->route('admin.dashboard')->with('status', 'Now managing ' . $user->name . '’s portfolio.');
    }
}
