const { createClient } = require("@supabase/supabase-js");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

module.exports = async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") return res.status(200).end();
  if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

  const { identifier, password } = req.body || {};
  if (!identifier || !password) {
    return res.status(400).json({ error: "Email/username and password are required." });
  }

  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
  const identifierLower = identifier.trim().toLowerCase();

  const { data: user, error } = await supabase
    .from("users")
    .select("*")
    .or(`email.eq.${identifierLower},username_lower.eq.${identifierLower}`)
    .maybeSingle();

  if (error) return res.status(500).json({ error: "Database error." });
  if (!user) return res.status(401).json({ error: "Invalid credentials." });

  if (user.status === "locked") {
    return res.status(403).json({ error: "Account is locked. Please try again later." });
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    const attempts = (user.login_attempts || 0) + 1;
    const updates = { login_attempts: attempts, last_failed_login: new Date().toISOString() };
    if (attempts >= 5) updates.status = "locked";
    await supabase.from("users").update(updates).eq("id", user.id);
    return res.status(401).json({ error: "Invalid credentials." });
  }

  await supabase.from("users").update({
    login_attempts: 0,
    last_login_at: new Date().toISOString(),
    last_failed_login: null,
  }).eq("id", user.id);

  const token = jwt.sign({ sub: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: "30d" });

  return res.status(200).json({
    token,
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      profile_image_name: user.profile_image_name,
      custom_profile_image_url: user.custom_profile_image_url,
      bio: user.bio,
      status: user.status,
      created_at: user.created_at,
    },
  });
};
