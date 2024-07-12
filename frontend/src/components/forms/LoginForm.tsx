import {
  Box,
  Button,
  FormControl,
  FormErrorMessage,
  FormLabel,
  Input,
  Link,
  Text,
  useToast,
} from "@chakra-ui/react";
import { useMutation } from "@tanstack/react-query";
import axios from "axios";
import { SubmitHandler, useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";
import {
  Navigate,
  Link as ReactRouterLink,
  useNavigate,
} from "react-router-dom";
import LoginBg from "../../assets/images/login-bg.png";
import { axiosInstance } from "../../api/axiosInstance";

type LoginValues = {
  email: string;
  password: string;
};

const LoginForm = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  if (localStorage.getItem("token")) {
    return <Navigate to="/" />;
  }

  const toast = useToast();
  const {
    handleSubmit,
    register,
    formState: { errors },
  } = useForm<LoginValues>();

  const mutation = useMutation({
    mutationFn: (values: LoginValues) => {
      return axiosInstance.post("/login", values);
    },
    onSuccess: (res) => {
      localStorage.setItem("token", res.data.token);
      localStorage.setItem("student_id", res.data.user.student_id);
      localStorage.setItem("name", res.data.user.name);
      localStorage.setItem("role", res.data.user.role);

      if (res.data.user.role === "student") {
        navigate("/course-selection");
      } else {
        navigate("/admin-panel");
      }
      toast({
        title: t("welcome"),
        status: "success",
        duration: 3000,
      });
    },
    onError: (error: any) => {
      toast({
        title: t("error"),
        description: `${error.response.data.error}`,
        status: "error",
        duration: 3000,
      });
    },
  });

  const onSubmit: SubmitHandler<LoginValues> = (values) => {
    mutation.mutate(values);
  };

  return (
    <Box
      height="100vh"
      display="flex"
      justifyContent="center"
      alignItems="center"
      flexDirection="row-reverse"
      padding="50px 140px"
    >
      <img
        style={{ flexBasis: "50%", height: "100%", objectFit: "contain" }}
        src={LoginBg}
        alt="login background"
      />
      <Box
        display="flex"
        flexDirection="column"
        flexBasis="50%"
        minWidth="400px"
        border="1px solid #C3C3C3"
        borderRadius="15px"
        padding="40px 60px"
      >
        <Text textAlign="center" fontWeight="700" fontSize="4xl">
          {t("login")}
        </Text>
        <form style={{ marginTop: "20px" }} onSubmit={handleSubmit(onSubmit)}>
          <FormControl isInvalid={!!errors.email}>
            <FormLabel htmlFor="email">{t("email")}</FormLabel>
            <Input
              id="email"
              {...register("email", {
                required: t("formMessages.emailIsRequired"),
              })}
            />
            <FormErrorMessage>
              {errors.email && errors.email.message}
            </FormErrorMessage>
          </FormControl>
          <FormControl mt="10px" isInvalid={!!errors.password}>
            <FormLabel htmlFor="password">{t("password")}</FormLabel>
            <Input
              type="password"
              id="password"
              {...register("password", {
                required: t("formMessages.passwordIsRequired"),
              })}
            />
            <FormErrorMessage>
              {errors.password && errors.password.message}
            </FormErrorMessage>
          </FormControl>

          <Box mt="20px">
            <span>{t("dontHaveAccount")}</span>{" "}
            <Link color="blue" as={ReactRouterLink} to="/signup">
              {t("signup")}
            </Link>
          </Box>
          <Box mt="20px" display="flex" justifyContent="center">
            <Button color="white" bg="primary.400" type="submit">
              {t("accept")}
            </Button>
          </Box>
        </form>
      </Box>
    </Box>
  );
};

export default LoginForm;
