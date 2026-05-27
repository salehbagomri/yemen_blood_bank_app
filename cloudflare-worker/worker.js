// Cloudflare Worker — Reverse Proxy for Supabase
// يمرر كل الطلبات من التطبيق إلى Supabase لتجاوز الحجب
//
// 🔧 الاستخدام:
// 1. انسخ هذا الكود كاملاً
// 2. ادخل https://dash.cloudflare.com → Workers & Pages → Create Worker
// 3. سمّه: yemen-blood-bank-proxy
// 4. الصق هذا الكود → Deploy

const SUPABASE_URL = 'https://mgeshfxrcdilwjohoniv.supabase.co';

export default {
  async fetch(request, env, ctx) {
    // التعامل مع CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(),
      });
    }

    try {
      const url = new URL(request.url);

      // بناء عنوان Supabase الحقيقي
      const targetUrl = SUPABASE_URL + url.pathname + url.search;

      // نسخ كل الهيدرات من الطلب الأصلي
      const headers = new Headers(request.headers);

      // حذف هيدرات غير ضرورية قد تسبب مشاكل
      headers.delete('host');
      headers.delete('cf-connecting-ip');
      headers.delete('cf-ray');
      headers.delete('cf-visitor');
      headers.delete('cf-worker');

      // تمرير الطلب إلى Supabase
      const response = await fetch(targetUrl, {
        method: request.method,
        headers: headers,
        body: request.method !== 'GET' && request.method !== 'HEAD'
          ? request.body
          : undefined,
      });

      // نسخ الاستجابة مع إضافة CORS headers
      const responseHeaders = new Headers(response.headers);
      Object.entries(corsHeaders()).forEach(([key, value]) => {
        responseHeaders.set(key, value);
      });

      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: responseHeaders,
      });

    } catch (error) {
      return new Response(
        JSON.stringify({ error: 'Proxy error', message: error.message }),
        {
          status: 502,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders(),
          },
        }
      );
    }
  },
};

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Max-Age': '86400',
  };
}
