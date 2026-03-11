const { createClient } = require("@supabase/supabase-js");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { randomUUID } = require("crypto");

module.exports = async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") return res.status(200).end();
  if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

  const { username, email, password } = req.body || {};
  if (!username || !email || !password) {
    return res.status(400).json({ error: "Username, email, and password are required." });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: "Password must be at least 6 characters." });
  }

  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
  const emailLower = email.trim().toLowerCase();
  const usernameLower = username.trim().toLowerCase();

  const { data: existingEmail } = await supabase
    .from("users").select("id").eq("email", emailLower).maybeSingle();
  if (existingEmail) return res.status(409).json({ error: "An account with this email already exists." });

  const { data: existingUsername } = await supabase
    .from("users").select("id").eq("username_lower", usernameLower).maybeSingle();
  if (existingUsername) return res.status(409).json({ error: "This username is already taken." });

  const passwordHash = await bcrypt.hash(password, 12);
  const userId = randomUUID();

  const { data: newUser, error } = await supabase.from("users").insert({
    id: userId,
    username: username.trim(),
    username_lower: usernameLower,
    email: emailLower,
    password_hash: passwordHash,
    profile_image_name: "avatar_1",
    bio: "",
    status: "active",
  }).select().single();

  if (error) {
    return res.status(500).json({ error: "Failed to create account. Please try again." });
  }

  const token = jwt.sign({ sub: newUser.id, email: newUser.email }, process.env.JWT_SECRET, { expiresIn: "30d" });

  return res.status(201).json({
    token,
    user: {
      id: newUser.id,
      username: newUser.username,
      email: newUser.email,
      profile_image_name: newUser.profile_image_name,
      custom_profile_image_url: newUser.custom_profile_image_url,
      bio: newUser.bio,
      status: newUser.status,
      created_at: newUser.created_at,
    },
  });
};
