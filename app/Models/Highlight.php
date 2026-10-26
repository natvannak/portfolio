<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Highlight extends Model
{
    protected $table = 'highlights';

    protected $guarded = ['id', 'user_id'];
}
