import React, { useState } from "react";
import {
  FormControl,
  FormLabel,
  FormErrorMessage,
  FormHelperText,
  Input,
  Button,
  Box,
  CheckboxGroup,
  Checkbox,
  Stack,
  useToast,
} from "@chakra-ui/react";
import { useTranslation } from "react-i18next";
import { SubmitHandler, useForm } from "react-hook-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { axiosInstance } from "../../../api/axiosInstance";
import { convertToAMPM } from "../../../utils";

type CourseInputs = {
  name: string;
  professor: string;
  days: any;
  fromTime?: string;
  toTime?: string;
  time: string;
};

const AddCourseForm = (props: { onSubmitForm: () => void }) => {
  const { t } = useTranslation();
  const [daysOfWeek, setDaysOfWeek] = useState<string[]>([]);
  const [showDaysError, setShowDaysError] = useState(false);

  const toast = useToast();
  const {
    handleSubmit,
    register,
    formState: { errors },
  } = useForm<CourseInputs>();
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: (values: CourseInputs) => {
      return axiosInstance.post("/courses/create", values);
    },
    onSuccess: (res) => {
      toast({
        title: t("courseAddedTitle"),
        description: `Course Added with id of ${res.data.course.course_id}`,
        status: "success",
        duration: 3000,
      });
      queryClient.invalidateQueries({ queryKey: ["total-courses"] });
      props.onSubmitForm();
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

  const submitHandler: SubmitHandler<CourseInputs> = (values) => {
    if (daysOfWeek.length === 0) {
      setShowDaysError(true);
      return;
    }

    mutation.mutate({
      days: daysOfWeek,
      name: values.name,
      professor: values.professor,
      time:
        convertToAMPM(values.fromTime) + " - " + convertToAMPM(values.toTime),
    });
  };

  return (
    <form onSubmit={handleSubmit(submitHandler)}>
      <FormControl isInvalid={!!errors.name}>
        <FormLabel>{t("courseName")}</FormLabel>
        <Input
          {...register("name", {
            required: t("nameRequired"),
          })}
          bg="#F3F4FF"
        />
        <FormErrorMessage>
          {errors.name && errors.name.message}
        </FormErrorMessage>
      </FormControl>
      <FormControl isInvalid={!!errors.professor} mt="20px">
        <FormLabel>{t("professor")}</FormLabel>
        <Input
          {...register("professor", {
            required: t("professorRequired"),
          })}
          bg="#F3F4FF"
        />
        <FormErrorMessage>
          {errors.professor && errors.professor.message}
        </FormErrorMessage>
      </FormControl>

      <FormControl mt="20px" as="fieldset">
        <FormLabel as="legend">{t("daysOfWeek")}</FormLabel>
        <CheckboxGroup
          value={daysOfWeek}
          onChange={(e) => {
            setDaysOfWeek(e as string[]);
          }}
        >
          <Stack
            direction="row"
            wrap="wrap"
            bg="#F3F4FF"
            padding="20px"
            borderRadius="10px"
            spacing="24px"
          >
            <Checkbox value="Saturday">{t("saturday")}</Checkbox>
            <Checkbox value="Sunday">{t("sunday")}</Checkbox>
            <Checkbox value="Monday">{t("monday")}</Checkbox>
            <Checkbox value="Tuesday">{t("tuesday")}</Checkbox>
            <Checkbox value="Wednesday">{t("wednesday")}</Checkbox>
            <Checkbox value="Thursday">{t("thursday")}</Checkbox>
          </Stack>
        </CheckboxGroup>
        {showDaysError && (
          <FormErrorMessage>{t("daysRequired")}</FormErrorMessage>
        )}
      </FormControl>

      <FormControl isInvalid={!!errors.fromTime || !!errors.toTime} mt="20px">
        <FormLabel>{t("classTime")}</FormLabel>
        <Box
          display="flex"
          justifyContent="space-between"
          alignItems="center"
          gap="20px"
        >
          <Input
            {...register("fromTime", {
              required: "from time is required",
            })}
            placeholder={t("fromTime")}
            bg="#F3F4FF"
          />
          <Input
            {...register("toTime", {
              required: "to time is required",
            })}
            placeholder={t("toTime")}
            bg="#F3F4FF"
          />
        </Box>
        <FormErrorMessage>
          {(errors.fromTime || errors.toTime) && t("timeIsRequired")}
        </FormErrorMessage>
      </FormControl>

      <Box mt="20px" display="flex" justifyContent="center" alignItems="center">
        <Button width="100px" bg="primary.400" color="#fff" type="submit">
          {t("accept")}
        </Button>
      </Box>
    </form>
  );
};

export default AddCourseForm;
