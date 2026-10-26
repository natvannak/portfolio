<?php

namespace App\Support;

use App\Models\User;

class Portfolio
{
    /**
     * The user whose portfolio is being edited. Normally the logged-in user;
     * an admin can "manage" any other user (stored in the session).
     */
    public static function target(): User
    {
        $auth = auth()->user();

        if ($auth->isAdmin() && ($id = session('managing_user_id'))) {
            $user = User::find($id);
            if ($user) {
                return $user;
            }
            session()->forget('managing_user_id');
        }

        return $auth;
    }

    public static function isManagingOther(): bool
    {
        return self::target()->id !== auth()->id();
    }
}
