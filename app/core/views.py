from django.conf import settings
from django.http import JsonResponse
from django.shortcuts import render


def home(request):
    context = {
        "version": settings.APP_VERSION,
        "commit": settings.GIT_COMMIT[:7] if settings.GIT_COMMIT else "local",
        "deployed_at": settings.DEPLOYED_AT,
    }
    return render(request, "core/index.html", context)


def health(request):
    return JsonResponse({"status": "ok"})
