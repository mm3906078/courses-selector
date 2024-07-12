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

type RegisterValues = {
  email: string;
  password: string;
  name: string;
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
  } = useForm<RegisterValues>();

  const mutation = useMutation({
    mutationFn: (values: RegisterValues) => {
      return axiosInstance.post("/register", {
        ...values,
        role: "student",
      });
    },
    onSuccess: (res) => {
      navigate("/login");
      toast({
        title: "Account Created Successfully!",
        status: "success",
        duration: 5000,
        isClosable: true,
      });
    },
    onError: (error: any) => {
      toast({
        title: "Error!",
        description: `${error.response.data}`,
        status: "error",
        duration: 5000,
        isClosable: true,
      });
    },
  });

  const onSubmit: SubmitHandler<RegisterValues> = (values) => {
    mutation.mutate(values);
  };

  return (
    <Box
      height="100vh"
      display="flex"
      justifyContent="space-between"
      alignItems="center"
      flexDirection="row-reverse"
      padding="40px 140px 0 40px"
      gap="100px"
      overflow="auto"
    >
      <img
        style={{ height: "100%", width: "50vw", objectFit: "cover" }}
        src={LoginBg}
        alt="login background"
      />
      <Box
        display="flex"
        flexDirection="column"
        minWidth="400px"
        width="50vw"
        border="1px solid #C3C3C3"
        borderRadius="15px"
        padding="40px 60px"
      >
        <Text textAlign="center" fontWeight="700" fontSize="4xl">
          {t("signup")}
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
          <FormControl mt="10px" isInvalid={!!errors.name}>
            <FormLabel htmlFor="name">{t("name")}</FormLabel>
            <Input
              type="name"
              id="name"
              {...register("name", {
                required: t("formMessages.nameIsRequired"),
              })}
            />
            <FormErrorMessage>
              {errors.name && errors.name.message}
            </FormErrorMessage>
          </FormControl>

          <Box mt="20px">
            <span>{t("alreadyHaveAccount")}</span>{" "}
            <Link color="blue" as={ReactRouterLink} to="/login">
              {t("login")}
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
