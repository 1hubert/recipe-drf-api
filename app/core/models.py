"""
Database models.
"""
from django.db import models
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin
)


class UserManager(BaseUserManager):
    """Manager for users."""

    # extra fields allow any number of keyword args
    def create_user(self, email, password=None, **extra_fields):
        """Create, save and return a new user."""
        # Because our manager is associated to a model, we need to access the model that we are associated with
        # self.model is the same as defining a new user class
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)

        return user


# Create your models here.
class User(AbstractBaseUser, PermissionsMixin):
    """User in the system."""
    email = models.EmailField(max_length=255, unique=True)
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=True)

    objects = UserManager()

    # Replace the default username field to custom email field
    USERNAME_FIELD = 'email'
