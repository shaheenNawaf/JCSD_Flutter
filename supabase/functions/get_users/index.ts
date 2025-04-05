import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { data, error } = await supabase.auth.admin.listUsers()

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    })
  }

  const safeUsers = data.users.map((user) => ({
    id: user.id,
    email: user.email,
    phone: user.phone,
    name: user.user_metadata?.name ?? 'NULL',
  }))

  return new Response(JSON.stringify(safeUsers), {
    headers: { 'Content-Type': 'application/json' },
    status: 200,
  })
})